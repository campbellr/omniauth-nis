require 'rack'
require "unix_crypt"
module OmniAuth
  module NIS
    class Adaptor
      class NISError < StandardError; end
      class ConfigurationError < StandardError; end
      class AuthenticationError < StandardError; end
      class ConnectionError < StandardError; end

      def initialize(configuration={})
        @configuration = configuration.dup
        @configuration[:allow_anonymous] ||= false
        @logger = @configuration.delete(:logger)
        VALID_ADAPTER_CONFIGURATION_KEYS.each do |name|
          instance_variable_set("@#{name}", @configuration[name])
        end
      end
      def auth_user(conf={})
        passwd = yp_match(conf[:username]).split(':')
        original_crypted = passwd[1]
        if UnixCrypt.valid?(conf[:password], original_crypted)
            names = passwd[4].split(' ', 2)
            if names
                first_name = names[0]
                last_name = names[1]
                name = first_name + ' ' + last_name
                email = "#{first_name}.#{last_name}@emc.com"
            else
                first_name = last_name = ''
                name = conf[:username]
                email = ''
            end
            return {'uid' => conf[:username],
                    'name'=> name,
                    'email'=> email,
                    'first_name' => first_name,
                    'last_name' => last_name}
        else
            return false
        end
      end
      def yp_match(username)
        output = `ypmatch #{username} passwd`
        raise "a NIS error has ocurred" unless $?.success?
        return output
      end
    end
  end
end
