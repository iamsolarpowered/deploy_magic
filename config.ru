require 'rubygems'
require 'vendor/rack/lib/rack'
require 'vendor/sinatra/lib/sinatra.rb'

set :environment, :development
set :raise_errors, true
disable :run

require 'deploy'

run Sinatra.application
