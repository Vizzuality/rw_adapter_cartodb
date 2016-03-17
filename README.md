# Resource Watch Service Connector for CartoDB

[![Build Status](https://travis-ci.org/Vizzuality/rw_adapter_cartodb.svg?branch=master)](https://travis-ci.org/Vizzuality/rw_adapter_cartodb)

TODO: Write a project description

## Installation

Requirements:

* Ruby 2.3.0 [How to install](https://gorails.com/setup/osx/10.10-yosemite)
* PostgreSQL 9.4+ [How to install](http://exponential.io/blog/2015/02/21/install-postgresql-on-mac-os-x-via-brew/)

Install global dependencies:

    gem install bundler

Install project dependencies:

    bundle install

## Usage

First time execute:
  checkout feature/users on this [repository](https://github.com/Vizzuality/resource-watch/tree/feature/users) and execute:

    bundle exec rake db:create
    bundle exec rake db:migrate

To run application:

    bundle exec rails server

## TEST

  Run rspec:

    bin/rspec

Run rspec for single engine:

    rspec spec/core
    rspec spec/rw_api
    rspec spec/etc...

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b feature/my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin feature/my-new-feature`
5. Submit a pull request :D

### BEFORE CREATING A PULL REQUEST

  Please check all of [these points](https://github.com/Vizzuality/rw_adapter_cartodb/blob/master/CONTRIBUTING.md).

