When /^I (?:am using|switch to) session "([^"]+)"$/ do |new_session_name|
  Capybara.session_name = new_session_name
end