# TAHI

[![Circle CI](https://circleci.com/gh/Tahi-project/tahi/tree/master.svg?style=svg&circle-token=8f8d8e64dc324b8dd1af4e141632a46cffe78702)](https://circleci.com/gh/Tahi-project/tahi/tree/master)



# Initial Setup

## Overview

1. Run the partial setup script (`bin/setup`)
1. Make sure the following servers are already running:
    - PostgreSQL
    - Redis (run manually with `redis-server`)
1. Clone the event server repo (`tahi-slanger`) in a sibling directory
1. Make sure the following ports are clear:
    - 4567 (Slanger API)
    - 8080 (Slanger websocket)
    - 5000 (Rails server)
1. Run with `foreman start`

## Partial Automated Setup

- Clone the repo, then run

```console
./bin/setup
```

## Event server

- Clone the [tahi-slanger](https://github.com/Tahi-project/tahi-slanger) github
  repository and follow the installation instructions

- Make sure `EVENT_STREAM_KEY` and `EVENT_STREAM_SECRET` are set in your environment.

When you run `foreman start`, slanger will start up as the event stream server.

By default, slanger will listen on port `4567` for API requests (requests
coming from tahi rails server) and port `8080` for websocket requests (from
tahi browser client).

# Running the server

We're using Foreman to run everything in dev.  Run `foreman start` to start the
server with the correct Procfile.

## Inserting test data

Run `rake db:setup`. This will delete any data you already have in your
database, and insert test users based on what you see in `db/seeds.rb`.

## Sending Emails

In development we sent emails through a simple SMTP server which catches any
message sent to it to display in a web interface

If you are running mailcatcher already you are ready to go, if not, please
follow these instructions:
 - install the gem `gem install mailcatcher`.
 - run in the console `mailcatcher` to start the daemon.
 - Go to http://localhost:1080/

For more information check http://mailcatcher.me/

# Tests

## Running specs

- RSpec for unit and integration specs
- Capybara and Selenium

In the project directory, running `rspec` will run all unit and integration
specs. Firefox will pop up to run integration tests.

## Running qunit tests from the command line

You can run the javascript specs via the command line with `rake ember:test`.

## Running qunit tests from the browser

You can also run the javascript specs from the browser. To do this, visit http://localhost:5000/ember-tests/tahi.

For help writing ember tests please see the [ember-cli testing section](http://www.ember-cli.com/#testing)

# Dev Notes

## Page Objects

When creating fragments, you can pass the context, if you wish to have access to
the page the fragment belongs to. You've to pass the context as an option to the
fragment on initializing:

```ruby
EditModalFragment.new(find('tr'), context: page)
```

## Configuring S3 direct uploads

Get access to S3 and make a new IAM user, for security reasons. Then take these
keys and use them. (If someone has already set this up, reuse their keys).

Ensure that the following environment variables are set:

```
S3_URL=http://your-s3-bucket.amazonaws.com
S3_BUCKET=your-s3-bucket
AWS_ACCESS_KEY=your-aws-access-key-id
AWS_SECRET_KEY=your-aws-secret-key
AWS_REGION=us-west-1 or us-east-2, etc.
```

Then, you need to configure your s3 bucket for CORS:

1. Download the AWS cli:
  - Darwin: `brew install awscli`
  - Linux: `sudo pip install awscli`
2. Run the following command from the app's root directory:
  ```
  aws s3api put-bucket-cors --bucket <your s3 bucket> --cors-configuration file://config/services/s3.cors.development.json
  ```

## Load testing

To wipe and restore performance data in a pristine state on tahi-performance,
run the following:

```
heroku pgbackups:restore HEROKU_POSTGRESQL_CYAN_URL b001 --app tahi-performance
```

A fully-loaded database with thousands of records can be found on S3 here:

```
tahi-performance/tahi_performance_backup.sql.zip
```

This can be downloaded and loaded locally, if needed.

The following rake task will create a new set of performance test data from scratch using FactoryGirl factories:

```
RAILS_ENV=performance bundle exec rake data:load:all
```

This will take several days to reconstruct, so you will probably want to use one of the above steps instead.

## Subset Load testing

Subset data contains about 100 users and some associated records.

To wipe and restore performance data in a pristine state on tahi-performance,
run the following:

```
heroku pgbackups:restore HEROKU_POSTGRESQL_CYAN_URL b002 --app tahi-performance
```

## Postgres Backups

Backups should be run automatically every day. If you would like to run one
manually run `heroku pg:backups capture`

You can get the URL to download a backup by running `heroku pg:backups public-url`

To list current backups `heroku pg:backups`

Your output should look something like this:

```
ID    Backup Time                Status                                Size     Database
----  -------------------------  ------------------------------------  -------  -----------------------------------------
b014  2014/08/27 14:56.44 +0000  Finished @ 2014/08/27 14:56.49 +0000  441.7KB  HEROKU_POSTGRESQL_ROSE_URL (DATABASE_URL)
b015  2014/09/02 13:35.44 +0000  Finished @ 2014/09/02 13:35.48 +0000  465.2KB  HEROKU_POSTGRESQL_ROSE_URL (DATABASE_URL)
b016  2014/09/11 14:42.05 +0000  Finished @ 2014/09/11 14:42.08 +0000  495.7KB  HEROKU_POSTGRESQL_ROSE_URL (DATABASE_URL)
b017  2014/09/16 15:07.00 +0000  Finished @ 2014/09/16 15:07.03 +0000  515.0KB  HEROKU_POSTGRESQL_ROSE_URL (DATABASE_URL)
b018  2014/10/01 12:41.31 +0000  Finished @ 2014/10/01 12:41.35 +0000  528.0KB  HEROKU_POSTGRESQL_ROSE_URL (DATABASE_URL)
b019  2014/10/09 17:48.40 +0000  Finished @ 2014/10/09 17:48.49 +0000  568.5KB  HEROKU_POSTGRESQL_ROSE_URL (DATABASE_URL)
b020  2014/10/13 13:10.26 +0000  Finished @ 2014/10/13 13:10.30 +0000  576.2KB  HEROKU_POSTGRESQL_ROSE_URL (DATABASE_URL)
b021  2014/10/16 14:04.13 +0000  Finished @ 2014/10/16 14:04.18 +0000  593.2KB  HEROKU_POSTGRESQL_ROSE_URL (DATABASE_URL)
```

To restore to a specific backup, use the ID and Database in your list output.
E.G.

```
heroku pgbackups:restore HEROKUPOSTGRESQL_ROSE_URL b020
```

# Documentation

Open the generated documentation from `doc/rdoc/index.html` in your browser.

To generate documentation, run the following command from the application root:

```
sdoc -g --markup=tomdoc --title="Tahi Documentation" --main="README.md" -o doc/rdoc -T sdoc app/models/**/*.rb
```

We are using [Tomdoc](http://tomdoc.org/) documentation specification format. We are currently aiming to have all models documented.
