# TAHI

[![Circle CI](https://circleci.com/gh/Tahi-project/tahi/tree/master.svg?style=svg&circle-token=8f8d8e64dc324b8dd1af4e141632a46cffe78702)](https://circleci.com/gh/Tahi-project/tahi/tree/master)



# Initial Setup

## Overview

1. Run the partial setup script (`bin/setup`)
1. Make sure the following servers are already running:
    - PostgreSQL
    - Redis (run manually with `redis-server`)
1. Make sure the following ports are clear:
    - 4567 (Slanger API)
    - 40604 (Slanger websocket)
    - 5000 (Rails server)
1. Run with `foreman start`

## Partial Automated Setup

- Clone the repo, then run

```console
./bin/setup
```

## Environment Variables

Tahi uses the [Dotenv](https://github.com/bkeepers/dotenv/) gem to manage its environment
variables in non-deployment environments (where Heroku manages the ENV). All necessary files
should be generated by the `bin/setup` script.

There are 4 important environment files: `.env`, `.env.development`, `.env.test`, `.env.local`.
`Dotenv` will load them in _that order_. Settings from `.env` will be overridden in the
`.env.(development/test)`, which will be overridden by the `.env.local`. Only the `.env` and
`.env.test` files are checked in. The `.env` file specifies some reasonable defaults for most
developer setups.

It is recommended to make machine specific modifications to the `.env.development`. Making
changes to the `.env.local` will override any settings from the `.env.test` (this can lead
to surprising differences between your machine and the CI server). This differs from the
"Dotenv best practices" which encourage making local changes to `.env.local`; we do not recommend
that approach.

foreman can also load environment variables. It is recommended that you do not
use it for this purpose, as interaction with dotenv can lead to bizarre `.env`
file load orders. Your `.foreman` file should contain the line:

```
env: ''
```

to prevent `.env` file loading.

## Event server

- The event server (slanger) is automatically installed in the setup script.

When you run `foreman start`, slanger will start up as the event stream server.

By default, slanger will listen on port `4567` for API requests (requests
coming from tahi rails server) and port `40604` for websocket requests (from
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

## Upgrading node packages

To upgrade a node package, e.g., to version 1.0.1, use:
```
cd client
npm install my-package@1.0.1 --save
npm shrinkwrap
```

This should update both the `client/package.json` and
`client/npm-shrinkwrap.json` files. Commit changes to both these files.

# Tests

## Running specs

- RSpec for unit and integration specs
- Capybara and Selenium

### Running application specs

In the project directory, running `rspec` will run all unit and integration
specs for the application. Firefox will pop up to run integration tests.

### Running engine specs

There are a number of Rails engines in the `engines/` directory. To run those point the `rspec` command to their `spec/` directory, e.g.:

```
rspec engines/plos_bio_tech_check/spec/
```

It's important that the `rspec` command is run from the application directory and not the engine directory when running as they share dependencies that are loaded with the `RAILS_ROOT/spec/rails_helper.rb`

### Running vendored/gems specs

The Tahi application vendors gem(s) that are private and do not fall into the category of Rails engines. These are placed in the `vendor/gems/` directory.

Their tests can be run by `cd`'ing into the gem directory and running rspec directly, e.g.:

```
cd vendor/gems/tahi_epub
rspec spec
```

Note: you may need to run `bundle install` in order to install the necessary test dependencies for vendored gems.

## Running qunit tests from the command line

You can run the javascript specs via the command line with `rake ember:test`.

## Running qunit tests from the browser

You can also run the javascript specs from the browser. To do this run
`ember test --serve` from `client/` to see the results in the
browser.
You can run a particular test with '--module'. For example, running:
`ember test --serve --module="Integration:Discussions"
will run the Ember test that starts with `module('Integration:Discussions', {`

For help writing ember tests please see the [ember-cli testing section](http://www.ember-cli.com/#testing)

## Other Dependencies

Ghostscript is required to pass some of the tests.  Ghostscript can be installed
by running:

`brew install ghostscript`

# Documentation

Technical documentation lives in the `doc/`.  The git workflow and deploy
process are documented in [doc/git-process.txt](doc/git-process.txt). There is
a [Contribution Guide](CONTRIBUTING.md) that includes a Pull Request Checklist
template.

# Dev Notes

## Page Objects

When creating fragments, you can pass the context, if you wish to have access to
the page the fragment belongs to. You've to pass the context as an option to the
fragment on initializing:

```ruby
EditModalFragment.new(find('tr'), context: page)
```

## Why does package.json change all the time?

All of the cards in Tahi are external engines. While Rails Engines work great as backend extensions, there is no easy way to package add-ons within the same repository as engines and have them auto-detected by the application. Obviously, this is because these are two separate platforms. To make it easier for plugin developers to swap in different engines only from a Gemfile, we created an initializer that detects if these are Tahi plugins (all gems prefixed `tahi-`). The detected plugin's path is injected into the `ember-addon.paths` object in `package.json` on every server run. That’s why you see package.json change all the time.

There is no problem in committing and pushing `package.json`, the ember-addons object is flushed at every server run to get the fresh and correct paths from Tahi plugins.

## Configuring S3 direct uploads

To set up a new test bucket for your own use, run:

```bash
rake s3:create_bucket
```

You will be prompted for an AWS key/secret key pair. You can ask a team member
for these: they should only be used to bootstrap your new settings.

Your new settings will be printed to stdout, and you can copy these settings
into your `.env.development` file.

## PDF Support

The ability to upload and view PDFs is keyed off of a journal setting. To enable PDFs on a journal use:

```
Journal.find(id).update(pdf_allowed: true)
```

That will enable PDF uploads and display. To work with PDFs in a local setting, the pdf.js viewer assets need to be copied into the assets directory.

```
rake rake assets:bypass_pipeline:copy_pdfjsviewer
```

For deployments, the `assets:bypass_pipeline:copy_pdfjsviewer` task runs right after `assets:precompile`.

Finally, the s3 bucket you use for the PDF uploads needs to be correctly configured for CORS GET requests with something like:

```
 <CORSRule>
   <AllowedOrigin>*</AllowedOrigin>
   <AllowedMethod>GET</AllowedMethod>
   <MaxAgeSeconds>3000</MaxAgeSeconds>
   <ExposeHeader>Accept-Ranges</ExposeHeader>
   <ExposeHeader>Content-Range</ExposeHeader>
   <ExposeHeader>Content-Encoding</ExposeHeader>
   <ExposeHeader>Content-Length</ExposeHeader>
   <AllowedHeader>*</AllowedHeader>
 </CORSRule>
```

# Deploying Aperta

Please see the
[Release Information page on confluence](https://developer.plos.org/confluence/display/TAHI/Release+Information)
for information on how to deploy aperta

# Documentation

To generate documentation, run the following command from the application root:

```
rake doc:app
```

Open the generated documentation from `doc/api/index.html` or
`doc/client/index.html` (javascript) in your browser.

Please document Ruby code with
[rdoc](http://docs.seattlerb.org/rdoc/RDoc/Markup.html) and Javascript with
[yuidoc](http://yui.github.io/yuidoc/)
