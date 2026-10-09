# Ruby 2.2.5 / Rails 4.2 are both long EOL — this image pins the exact old
# Ruby version so the app keeps building regardless of what a host's native
# buildpack supports. It's also the right base for compiling therubyracer's
# bundled V8 (libv8 3.16): that C++ code reliably fails to compile under the
# gcc shipped with modern base images, but builds fine under the old gcc on
# this image's (Debian Jessie) base.
FROM ruby:2.2.5

# Debian Jessie was pulled from the regular apt mirror network and now only
# lives on archive.debian.org, with no currently-valid Release file. Point
# apt there and skip the timestamp check so `apt-get update` still works.
RUN sed -i \
      -e 's|deb.debian.org|archive.debian.org|g' \
      -e 's|security.debian.org|archive.debian.org/debian-security|g' \
      /etc/apt/sources.list \
 && apt-get -o Acquire::Check-Valid-Until=false update \
 && apt-get install -y --no-install-recommends \
      build-essential \
      libpq-dev \
      zlib1g-dev \
      patch \
      python \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Match the Bundler version this app's Gemfile.lock was generated with.
RUN gem install bundler -v 1.13.2 --no-document

COPY Gemfile Gemfile.lock ./
# mysql2 is a :development-only dependency (see Gemfile) and isn't needed
# here — production only uses pg, which libpq-dev above covers.
RUN bundle _1.13.2_ install --deployment --without development test doc --jobs 4

COPY . .

ENV RAILS_ENV=production

# Needs *some* secret_key_base to boot (see config/initializers/secret_token.rb).
# The real one is supplied at runtime via the SECRET_KEY_BASE env var/secret;
# this one-off value only needs to get precompile through boot.
RUN SECRET_KEY_BASE=$(ruby -rsecurerandom -e 'print SecureRandom.hex(64)') \
    bundle _1.13.2_ exec rake assets:precompile

EXPOSE 3000
CMD bundle _1.13.2_ exec rails server -b 0.0.0.0 -p ${PORT:-3000}
