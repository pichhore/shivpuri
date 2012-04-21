# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_studyroom_session',
  :secret      => 'cbb7d1b6ade0beb49bcd2d3caac74352312b668b53cbe2714c3b3561e8cdf27e27d08d4723b693cbdb872cd91e1949d1b540a40fcc09536c49be6b5dab381283'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
