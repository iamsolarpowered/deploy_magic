require 'sinatra/base'

module Sinatra
  module HTTPAuth
    module Helpers
      def authorize!
        response['WWW-Authenticate'] = %(Basic realm="Testing HTTP Auth") and \
        throw(:halt, [401, "Not authorized\n"]) and \
        return unless authorized?
      end

      def authorized?
        @auth ||=  Rack::Auth::Basic::Request.new(request.env)
        @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [options.username, options.password]
      end
    end

    def self.registered(app)
      app.helpers HTTPAuth::Helpers
    end
  end

  register HTTPAuth
end
