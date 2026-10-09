# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
#
# Read from the environment (set it as a secret on whatever host runs this)
# instead of hardcoding it, so this file is safe to commit. Falls back to a
# random per-boot value so things like `rake assets:precompile` still work
# when SECRET_KEY_BASE isn't set (e.g. during a Docker build).
require 'securerandom'
Pools::Application.config.secret_key_base =
  ENV.fetch('SECRET_KEY_BASE') { SecureRandom.hex(64) }
