# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'spork', :rspec_env => { 'RAILS_ENV' => 'test' },
               :wait => 60,
               :cucumber => false,
               :test_unit => false do
  watch('config/application.rb')
  watch('config/environment.rb')
  watch('config/routes.rb')
  watch(%r{^config/environments/.+\.rb$})
  watch(%r{^config/initializers/.+\.rb$})
  watch(%r{^Gemfile(\.lock)?$})
  watch(%r{^lib/(.+)\.rb$})
  watch(%r{^faye/(.+)\.rb$})
  watch('spec/spec_helper.rb')
  watch(%r{^spec/support/(.+)\.rb$})
  watch('spec/javascripts/support/jasmine.yml')
end

# Add files and commands to this file, like the example:
#   watch(%r{file/path}) { `command(s)` }
#
guard 'shell' do
  # watch(%r{file/path}) { `command(s)` }
end

class DbCleaner
  def call(guard_class, event, *args)
    puts 'Resetting sqlite3 test db...'
    `cp db/test.sqlite3.clean db/test.sqlite3`
  end
end

guard 'jasmine', :console => :always, :errors => :always, :timeout => 10000, :keep_failed => false, :all_after_pass => false do
  watch(%r{spec/javascripts/helpers/.*(js\.coffee|js|coffee)$})    { 'spec/javascripts' }
  watch(%r{spec/javascripts/spec\.(js\.coffee|js|coffee)$})        { 'spec/javascripts' }
  watch(%r{^spec/javascripts/.*_factory\..*})                      { 'spec/javascripts' }
  watch(%r{spec/javascripts/.+_spec\.(js\.coffee|js|coffee)$})
  watch(%r{app/assets/javascripts/(.+?)\.(js\.coffee|js|coffee)$}) { |m| "spec/javascripts/#{m[1]}_spec.#{m[2]}" }
  watch(%r{app/assets/javascripts/templates/(.+?)\.hamlc$})        { |m| "spec/javascripts/views/#{m[1]}_view_spec.coffee" }
  Hook.reset_callbacks!
  callback(DbCleaner.new, [:start_begin, :run_all_begin, :reload_begin, :run_on_change_begin])
end

guard 'rspec', :version => 2, :cli => "--drb -f Fuubar --colour" do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^lib/(.+)\.rb$})                           { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^lib/(.+)\.rake$})                         { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^faye/(.+)\.rb$})                          { |m| "spec/faye/#{m[1]}_spec.rb" }
  watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance"] }
  watch(%r{^spec/fabricators/(.+)\.rb$})              { "spec" }
  watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
  watch('spec/spec_helper.rb')                        { "spec" }
  watch('config/routes.rb')                           { "spec/routing" }
  watch('app/controllers/application_controller.rb')  { "spec/controllers" }
  # Capybara request specs
  watch(%r{^app/views/(.+)/(.*)\.(erb|haml)$})        { |m| ["spec/requests/#{m[1]}_spec.rb", "spec/views/#{m[1]}/#{m[2]}_spec.rb"] }
  # Steak acceptance specs
  watch('spec/faye/faye_helper.rb')                   { "spec/faye" }
  watch('spec/acceptance/acceptance_helper.rb')       { "spec/acceptance" }
  watch('app/assets/javascripts')                     { "spec/acceptance" }
  watch('app/assets/templates')                       { "spec/acceptance" }
end

# guard 'rails-assets' do
#   watch(%r{^app/assets/.*\.hamlc})
#   watch('config/application.rb')
# end

# spec_location = "spec/javascripts/%s_spec"
#
# guard 'jasmine-headless-webkit' do #, :run_before => 'bundle exec rake assets:clean assets:precompile RAILS_ENV=development' do
#   watch(%r{^app/assets/javascripts/(.*)\.(js|coffee)}) { |m| newest_js_file(spec_location % m[1]) }
#   watch(%r{^lib/assets/javascripts/(.*)\.(js|coffee)}) { |m| newest_js_file(spec_location % m[1]) }
#   watch(%r{^spec/javascripts/(.*)_spec\..*}) { |m| newest_js_file(spec_location % m[1]) }
#   watch(%r{^spec/javascripts/(.*)_factory\..*}) { "spec/javascripts" }
# end

# guard 'cucumber' do
#   watch(%r{^features/.+\.feature$})
#   watch(%r{^features/support/.+$})                      { 'features' }
#   watch(%r{^features/step_definitions/(.+)_steps\.rb$}) { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'features' }
# end

# guard 'livereload' do
#   watch(%r{app/views/.+\.(erb|haml|slim)})
#   watch(%r{app/helpers/.+\.rb})
#   watch(%r{public/.+\.(css|js|html)})
#   watch(%r{config/locales/.+\.yml})
#   # Rails Assets Pipeline
#   watch(%r{(app|vendor)/assets/\w+/(.+\.(css|js|html)).*})  { |m| "/assets/#{m[2]}" }
# end

guard 'pow' do
  watch('.powrc')
  watch('.powenv')
  watch('.rvmrc')
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('config/application.rb')
  watch('config/environment.rb')
  watch(%r{^config/environments/.*\.rb$})
  watch(%r{^config/initializers/.*\.rb$})
end
