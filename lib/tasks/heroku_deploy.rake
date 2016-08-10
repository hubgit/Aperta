namespace :heroku do
  desc <<-DESC.strip_heredoc
    This deploys to our Heroku environments, tahi-lean-workflow, tahi-sandbox01

    This optionally takes an app name if one wishes to deploy to a single Heroku environment.
    Examples:
      rake  heroku:deploy
      rake  heroku:deploy[tahi-lean-workflow]

    The first command will deploy to tahi-lean-workflow and tahi-sandbox
    The second command will deploy only to tahi-lean-workflow
    DESC
  task :deploy, [:app] => [:environment] do |_, args|
    DEPLOYING_APPS = ['tahi-lean-workflow', 'tahi-sandbox01']
    DEPLOYING_APPS = [args[:app]] if args[:app].present?
    puts "Deploying #{DEPLOYING_APPS.join(', ')}..."

    Benchmark.bm(10) do |x|
      x.report("threaded:") do
        DEPLOYING_APPS.each do |app|
          thr = Thread.new do
            `heroku run bundle exec rake db:migrate --app tahi-staging`
            puts "running commands for #{app}"
          end
          thr.join
        end
        puts "Completed deployment"
      end
    end

    # Benchmark.bm(10) do |x|
    #   x.report("not threaded:") do
    #     DEPLOYING_APPS.each do |app|
    #       `heroku run bundle exec rake db:migrate --app tahi-staging`
    #       puts "running commands for #{app}"
    #     end
    #     puts "Completed deployment"
    #   end
    # end
  end
end
