# How to run the benchmarks

Install Ruby, for instance by using the instructions on the [Ruby website](https://www.ruby-lang.org/en/downloads/).

Make sure you have an up to date version of RubyGems. If it is not already installed by the tool you used to install Ruby, install it using [these instructions](http://rubygems.org/pages/download).

Download the compressed source code for this project [here](https://github.com/krikis/nomad/archive/master.zip) to a local folder and unzip it.

Open the root of the project in a terminal to issue the following commands:

```bash
gem install bundler              # install a gem dependency manager
bundle                           # install the project's gems
bundle exec rake db:create       # instantiate an SQLite database
bundle exec rake db:setup        # load the database schema
bundle exec rails s              # start a development server on port 3000
bundle exec rake update_test_db  # clean copy of the database for benchmarking
RAILS_ENV='test' rake faye       # start the Faye WebSocket server on port 9292
```

Configure the Faye client by setting the following line in `app/assets/javascripts/logic/faye_client.coffee`:

```coffee
@FAYE_SERVER = 'http://localhost:9292/faye'
```

Navigate to http://localhost:3000/benchmarks to open the benchmark suite in your browser. You're ready to run the benchmarks!

For more information on this project, read the [thesis](https://github.com/krikis/nomad/blob/master/doc/thesis.pdf?raw=true).