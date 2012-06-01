desc "Update dev db and clone to test"
task :update_test_db do
  Rake::Task['db:test:clone'].invoke
  `cp db/test.sqlite3 db/test.sqlite3.clean`
end