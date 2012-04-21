require 'jsonifier/json_encoding'

ActiveRecord::Base.send :include, Jsonifier::JsonEncoding

