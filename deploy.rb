CONFIG = YAML.load_file('config.yml')

post '/:repo_name' do
  # Only allow requests from Github
  unless @request.env['REMOTE_ADDR'] == CONFIG['github_ip']
    throw :halt, [401, '<h1>Permission denied.</h1>']
  end

  repo_name = params[:repo_name]
  if repo = CONFIG['repos'][repo_name]
    cmd = ["cd #{repo['path']}"]
    cmd << "git pull #{repo['remote']} #{repo['branch']}"
    cmd << "rake db:migrate RAILS_ENV=#{repo['env']}"
    cmd << repo['restart_command']
    system(cmd.join(' && '))
    '<h1>Deployed :)</h1>'
  else
    throw :halt, [404, "<h1>Repo not found: #{repo_name}</h1>"]
  end
end
