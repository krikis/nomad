# How to run the benchmarks

For realistic benchmark results, especially on network load, the source code of this project should be deployed on a computer you can access through the internet (so, not a machine on your local area network). From now on this machine is referred to as the `benchmark_server`. On this benchmark server, do the following :

- Install Ruby, for instance by using the instructions on the [Ruby website](https://www.ruby-lang.org/en/downloads/).
- Make sure you have an up to date version of RubyGems. If it is not already installed by the tool you used to install Ruby, install it using [these instructions](http://rubygems.org/pages/download).
- Download the compressed source code for this project [here](https://github.com/krikis/nomad/archive/master.zip) and unzip it in a local folder.
- Open the root of the project in a terminal and issue the following commands:

```bash
gem install bundler                     # install a gem dependency manager
bundle                                  # install the project's gems
bundle exec rake db:create              # instantiate an SQLite database
bundle exec rake db:setup               # load the database schema
bundle exec rails s                     # start a development server on port 3000
```
- Open a new terminal window at the root of the project and do the following:

```bash
bundle exec rake update_test_db         # clean copy of the database for benchmarking
RAILS_ENV='test' bundle exec rake faye  # start the Faye WebSocket server on port 9292
```
- Configure the Faye client by replacing `benchmark_server` with the address of your benchmark server in the following line (in `app/assets/javascripts/logic/faye_client.coffee`):

```coffee
@FAYE_SERVER = 'http://benchmark_server:9292/faye'
```
- If the benchmark server is behind a firewall, do not forget to set up port forwarding for the Rails and Faye servers (ports 3000 and 9292 respectively).

The benchmark environment is all set up. Now drive to the computer you will use to run the benchmarks on. Install the [Chrome](https://www.google.com/intl/en/chrome/browser/) browser if you do not already have a version. Fire it up and navigate to `http://benchmark_server:3000` to open the benchmark suite. You're ready to run the benchmarks!

Got stuck somewhere halfway the instructions or in doubt on how to use the benchmark suite? Don't hesitate to contact me!

Samuel Esposito

***

For more information on this project, please read the [master thesis](https://github.com/krikis/nomad/blob/master/doc/thesis.pdf?raw=true).
