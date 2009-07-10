CONFIG = YAML.load_file('config.yml')

post '/:repo_name' do
  # Only allow requests from Github's IP (specified in config.yml)
  unless @request.env['REMOTE_ADDR'] == CONFIG['github_ip']
    throw :halt, [401, '<h1>Permission denied.</h1>']
  end

  repo_name = params[:repo_name]
  if repo = CONFIG['repos'][repo_name]
    ok = true
    ok = false unless system("#{repo['path']}/git pull #{repo['remote']} #{repo['branch']}")
    ok = false unless system("#{repo['path']}/rake db:migrate RAILS_ENV=#{repo['env']}")
    ok = false unless system("#{repo['path']}/repo['restart_command']")
    (ok ? '<h1>Deployed :)</h1>' : '<h1>Something went wrong :(')
  else
    throw :halt, [404, "<h1>Repo not found: #{repo_name}</h1>"]
  end
end
