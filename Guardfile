# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'spork', :rspec_env => { 'RAILS_ENV' => 'test' },
               :wait => 60,
               :cucumber => false,
               :test_unit => false do
  watch('config/application.rb')
  watch('config/environment.rb')
  watch(%r{^config/environments/.+\.rb$})
  watch(%r{^config/initializers/.+\.rb$})
  watch(%r{^lib/(.+)\.rb$})
  watch('spec/spec_helper.rb')
end

# guard 'rspec', :version => 2, :cli => "--drb -f Fuubar --colour" do
#   watch(%r{^spec/.+_spec\.rb$})
#   watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
#   watch('spec/spec_helper.rb')  { "spec" }
# 
#   # Rails example
#   watch(%r{^spec/.+_spec\.rb$})
#   watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
#   watch(%r{^lib/(.+)\.rb$})                           { |m| "spec/lib/#{m[1]}_spec.rb" }
#   watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance/#{m[1]}_spec.rb"] }
#   watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
#   watch(%r{^spec/fabricators/(.+)\.rb$})              { |m| "spec" }
#   watch('spec/spec_helper.rb')                        { "spec" }
#   watch('config/routes.rb')                           { "spec/routing" }
#   watch('app/controllers/application_controller.rb')  { "spec/controllers" }
#   # Capybara request specs
#   watch(%r{^app/views/(.+)/.*\.(erb|haml)$})          { |m| "spec/requests/#{m[1]}_spec.rb" }
# end

guard 'rails-assets' do
  watch(%r{^.*/assets/javascripts/.*\.(js|coffee)$})
  watch('config/application.rb')
end

spec_location = "spec/javascripts/%s_spec"

guard 'jasmine-headless-webkit' do
  watch(%r{^app/views/.*\.jst$})
  watch(%r{^public/javascripts/(.*)\.js$}) { |m| newest_js_file(spec_location % m[1]) }
  watch(%r{^.*/assets/javascripts/(.*)\.(js|coffee)$}) { |m| newest_js_file(spec_location % m[1]) }
  watch(%r{^spec/javascripts/(.*)_spec\..*}) { |m| newest_js_file(spec_location % m[1]) }
end
