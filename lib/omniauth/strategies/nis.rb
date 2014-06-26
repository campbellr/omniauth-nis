require 'omniauth'

module OmniAuth
  module Strategies
    class NIS
      include OmniAuth::Strategy
      option :title, "NIS Authentication" #default title for authentication form
      option :name_proc, lambda {|n| n}

      def request_phase
        f = OmniAuth::Form.new(:title => (options[:title] || "NIS Authentication"), :url => callback_path)
        f.text_field 'Login', 'username'
        f.password_field 'Password', 'password'
        f.button "Sign In"
        f.to_response
      end

      def callback_phase
        @adaptor = OmniAuth::NIS::Adaptor.new @options

        return fail!(:missing_credentials) if missing_credentials?
        begin
          @nis_user_info = @adaptor.auth_user(:username => request['username'], :password => request['password'])
          puts @nis_user_info
          return fail!(:invalid_credentials) if !@nis_user_info

          @user_info = @nis_user_info
          super
        rescue Exception => e
          return fail!(:nis_error, e)
        end
      end

      uid {
        @user_info["uid"]
      }
      info {
        @user_info
      }
      extra {
        { :raw_info => @nis_user_info }
      }

      protected

      def missing_credentials?
        request['username'].nil? or request['username'].empty? or request['password'].nil? or request['password'].empty?
      end # missing_credentials?
    end
  end
end

OmniAuth.config.add_camelization 'nis', 'NIS'

