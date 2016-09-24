require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Dwolla < OmniAuth::Strategies::OAuth2
      DEFAULT_SCOPE = 'accountinfofull'
      option :name, 'dwolla'
      option :client_options, {
        :site => 'https://www.dwolla.com',
        :authorize_url => '/oauth/v2/authenticate',
        :token_url => '/oauth/v2/token'
      }
      #option :provider_ignores_state, true
      # setting that has NO effect.
      # If anyone can figure a way to make it work
      # PLEASE issue a pull request. -masukomi

      uid { access_token.params['account_id'] }

      info do
        {
          'name'      => user['Name'],
          'latitude'  => user['Latitude'],
          'longitude' => user['Longitude'],
          'city'      => user['City'],
          'state'     => user['State'],
          'type'      => user['Type']
        }
      end

      extra do
        unless skip_info?
          { 'raw_info' => user }
        else
          {}
        end
      end

      def authorize_params
        super.tap do |params|
          params[:scope] ||= DEFAULT_SCOPE
        end
      end

      private

      def user
        @user ||= access_token.get('/oauth/rest/users/').parsed['Response']
      end
    end
  end
end
