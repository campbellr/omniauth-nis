require 'rack'
require "unix_crypt"
module OmniAuth
  module NIS
    class Adaptor
      class NISError < StandardError; end
      class ConfigurationError < StandardError; end
      class AuthenticationError < StandardError; end
      class ConnectionError < StandardError; end

      VALID_ADAPTER_CONFIGURATION_KEYS = [:domain, :email_domain, :allow_anonymous]

      attr_accessor :domain, :email_domain, :password

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
            if !names.empty?
                first_name = names[0]
                last_name = names.length == 2 ? names[1] : ''
                name = [first_name, last_name].join(' ').strip
                if @email_domain.nil?
                    email = ''
                else
                    email = "#{first_name}.#{last_name}@#{@email_domain}"
                end
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
        if @domain.nil?
            output = `ypmatch #{username} passwd`
        else
            output = `ypmatch -d #{@domain} #{username} passwd`
        end
        raise "a NIS error has ocurred" unless $?.success?
        return output
      end
    end
  end
end
