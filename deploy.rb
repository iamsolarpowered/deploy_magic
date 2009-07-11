require 'erb'
require 'builder'

CONFIG = YAML.load_file('config.yml')


use Rack::Auth::Basic do |username, password|
  [username, password] == [CONFIG['username'], CONFIG['password']]
end

post '/:repo_name' do
  repo_name = params[:repo_name]
  if repo = CONFIG['repos'][repo_name]
    @pulled = system("cd #{repo['path']} && git pull #{repo['remote']} #{repo['branch']}")
    @migrated = system("cd #{repo['path']} && rake db:migrate RAILS_ENV=#{repo['env']}")
    @restarted = system("cd #{repo['path']} && repo['restart_command']")
    builder :response
  else
    throw :halt, [404, "<h1>Repo not found: #{repo_name}</h1>"]
  end
end

get '/' do
  erb :index
end
