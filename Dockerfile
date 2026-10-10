# Ruby 2.2.5 / Rails 4.2 are both long EOL — this image pins the exact old
# Ruby version so the app keeps building regardless of what a host's native
# buildpack supports. It's also the right base for compiling therubyracer's
# bundled V8 (libv8 3.16): that C++ code reliably fails to compile under the
# gcc shipped with modern base images, but builds fine under the old gcc on
# this image's (Debian Jessie) base.
FROM ruby:2.2.5

# Debian Jessie (this image's base OS) was pulled from the live apt mirror
# network; archive.debian.org is the only place left to fetch from, and it
# serves Release files with a permanently-expired timestamp and no
# currently-trusted signature. `trusted=yes` + `check-valid-until=no` skip
# both checks for this one legacy repo — fine for a pinned, immutable base
# image's build-time toolchain, not a runtime trust boundary.
#
# Everything this app needs to compile (gcc/g++/make, libpq-dev, zlib1g-dev,
# patch, ...) is already present in the base image — it's what was used to
# build Ruby itself. The one thing missing is `python`, needed by
# therubyracer's bundled V8 (libv8), which still uses the old Python-based
# gyp build system.
RUN printf '%s\n' \
      'deb [check-valid-until=no trusted=yes] http://archive.debian.org/debian jessie main' \
      'deb [check-valid-until=no trusted=yes] http://archive.debian.org/debian-security jessie/updates main' \
      > /etc/apt/sources.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends python \
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
