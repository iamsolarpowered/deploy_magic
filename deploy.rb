CONFIG = YAML.load_file('config.yml')

post '/:repo_name' do
  # Only allow requests from Github's IP (specified in config.yml)
  unless @request.env['REMOTE_ADDR'] == CONFIG['github_ip']
    throw :halt, [401, '<h1>Permission denied.</h1>']
  end

  repo_name = params[:repo_name]
  if repo = CONFIG['repos'][repo_name]
    log = File.open(File.join(repo['path'], 'log', 'deploy.log'), 'a')
    log.write '**************************************'
    log.write "Starting deployment at #{Time.now}"
    pulled = system("cd #{repo['path']} && git pull #{repo['remote']} #{repo['branch']}")
    log.write "Pulled: #{pulled}"
    migrated = system("cd #{repo['path']} && rake db:migrate RAILS_ENV=#{repo['env']}")
    log.write "Migrated: #{migrated}"
    restarted = system("cd #{repo['path']} && repo['restart_command']")
    log.write "Restarted: #{restarted}"
    log.write "Finished."
    log.close
  else
    throw :halt, [404, "<h1>Repo not found: #{repo_name}</h1>"]
  end
end
