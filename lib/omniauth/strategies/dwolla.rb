require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Dwolla < OmniAuth::Strategies::OAuth2
      DEFAULT_SCOPE = 'accountinfofull'

      option :client_options, {
        :site => 'https://www.dwolla.com',
        :authorize_url => '/oauth/v2/authenticate',
        :token_url => '/oauth/v2/token'
      }

      uid { raw_info['Response']['Id'] }

      info do
        {
          :name => raw_info['Response']['Name'],
        }
      end
      
      extra do
        {
          :raw_info => raw_info['Response']
        }
      end

      def authorize_params
        super.tap do |params|
          params[:scope] ||= DEFAULT_SCOPE
        end
      end
      
      def raw_info
        access_token.options[:mode] = :query
        access_token.options[:param_name] = :oauth_token
        @raw_info ||= MultiJson.load(access_token.get('https://www.dwolla.com/oauth/rest/users/').body)
      end

     end
   end
end
