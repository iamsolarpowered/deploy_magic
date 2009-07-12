require 'erb'
require 'builder'
require 'lib/http_auth'

CONFIG = YAML.load_file('config.yml')

set :username, CONFIG['username']
set :password, CONFIG['password']

before do
  authorize!
end

post '/:repo_name' do
  repo_name = params[:repo_name]
  if @repo = CONFIG['repos'][repo_name]
    @pulled = system("cd #{@repo['path']} && git pull #{@repo['remote']} #{@repo['branch']}")
    @migrated = system("cd #{@repo['path']} && rake db:migrate RAILS_ENV=#{@repo['env']}")
    @restarted = system("cd #{@repo['path']} && #{@repo['restart_command']}")
  else
    throw :halt, [404, "<h1>Repo not found: #{repo_name}</h1>"]
  end
end

get '/' do
  erb :index
end
