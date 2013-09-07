# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_src_session',
  :secret      => '6a36396a72846cfc70689adcf1d649bf7c2f0a39590868ae5de98ab4ae410cd50f612eca78a15f6dfe2667b341751f6025fd26d4a99a6de37ebdbaa4ff6e46d5'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
