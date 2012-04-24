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
  watch(%r{^lib/(.+)\.rb$})
  watch('spec/spec_helper.rb')
  watch('spec/javascripts/support/jasmine.yml')
end

guard 'jasmine' do
  watch(%r{spec/javascripts/spec\.(js\.coffee|js|coffee)$})         { 'spec/javascripts' }
  watch(%r{^spec/javascripts/(.*)_factory\..*})                     { 'spec/javascripts' }
  watch(%r{spec/javascripts/.+_spec\.(js\.coffee|js|coffee)$})
  watch(%r{app/assets/javascripts/(.+?)\.(js\.coffee|js|coffee)$})  { |m| "spec/javascripts/#{m[1]}_spec.#{m[2]}" }
  watch('app/assets/templates')                                    { 'spec/javascripts' }
end

guard 'rspec', :version => 2, :cli => "--drb -f Fuubar --colour" do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^lib/(.+)\.rb$})                           { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance"] }
  watch(%r{^spec/fabricators/(.+)\.rb$})              { "spec" }
  watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
  watch('spec/spec_helper.rb')                        { "spec" }
  watch('config/routes.rb')                           { "spec/routing" }
  watch('app/controllers/application_controller.rb')  { "spec/controllers" }
  # Capybara request specs
  watch(%r{^app/views/(.+)/(.*)\.(erb|haml)$})        { |m| ["spec/requests/#{m[1]}_spec.rb", "spec/views/#{m[1]}/#{m[2]}.#{m[3]}_spec.rb"] }
  # Steak acceptance specs
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
