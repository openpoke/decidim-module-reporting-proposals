# Reporting proposals component for Decidim

[![[CI] Lint](https://github.com/openpoke/decidim-module-reporting-proposals/actions/workflows/lint.yml/badge.svg)](https://github.com/openpoke/decidim-module-reporting-proposals/actions/workflows/lint.yml)
[![[CI] Test (unit)](https://github.com/openpoke/decidim-module-reporting-proposals/actions/workflows/test_unit.yml/badge.svg)](https://github.com/openpoke/decidim-module-reporting-proposals/actions/workflows/test_unit.yml)
[![[CI] Test (integration)](https://github.com/openpoke/decidim-module-reporting-proposals/actions/workflows/test_integration.yml/badge.svg)](https://github.com/openpoke/decidim-module-reporting-proposals/actions/workflows/test_integration.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/1b469dba958dedd29046/maintainability)](https://codeclimate.com/github/openpoke/decidim-module-reporting-proposals/maintainability)
[![codecov](https://codecov.io/gh/openpoke/decidim-module-reporting-proposals/branch/main/graph/badge.svg?token=X11YWWSMO4)](https://codecov.io/gh/openpoke/decidim-module-reporting-proposals)
[![Gem Version](https://badge.fury.io/rb/decidim-reporting_proposals.svg)](https://badge.fury.io/rb/decidim-reporting_proposals)

This module creates a new component to be used in participatory spaces that allows to create proposals orientated to manage geolocated issues in a city. For instance Damages or new ideas of improving a particular street or public good.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'decidim-reporting_proposals', git: "https://github.com/openpoke/decidim-module-reporting_proposals"
```

And then execute:

```
bundle
And then execute:
bundle exec rails decidim_reporting_proposals:install:migrations
```

> **IMPORTANT:**
>
> This module makes use of the [Deface](https://github.com/spree/deface) gem.
> In conjuntion with other modules (we know [Term Customizer](https://github.com/mainio/decidim-module-term_customizer/) is one of them) it might cause errors when precompiling assets for production sites. But only if during this process the compiling machine does not have access to the database.
>
> It is easy to overcome this problem. Just add the following line to your `config/environments/production.rb` file:
> 
> ```ruby
> config.deface.enabled = ENV['DB_ADAPTER'].blank? || ENV['DB_ADAPTER'] == 'postgresql'
> ```
>
> Then precompile with these ENV enabled in your CI:
>
> ```bash
> DB_ADAPTER=nulldb RAILS_ENV=production rake assets:precompile
> ```
>
> Alternatively, use any other ENV var to set up the `config.deface.enabled` to `false` during the precompilation phase.

## Usage

This module works very similarly as the Proposals module, in fact, it extends it to provide additional features and some different defaults.

It provides a new component called "Reporting Proposals" that can be added in addition or instead of the Proposals component in any participatory space.

### Features

TODO...

### Customization

Almost all the features of this module can be customized through an initializer.

For instance, you can create an initializer an change some of the available options as follows (**This is optional, you don't need to do this, by default all options are enabled**):

```ruby
# config/initializers/reporting_proposals.rb

Decidim::ReportingProposals.configure do |config|
  # Public Setting that defines after how many days a not-answered proposal is overdue
  # Set it to 0 (zero) if you don't want to use this feature
  config.unanswered_proposals_overdue = 7

  # Public Setting that defines after how many days an evaluating-state proposal is overdue
  # Set it to 0 (zero) if you don't want to use this feature
  config.evaluating_proposals_overdue = 3

  # Public Setting that defines whether the administrator is allowed to hide the proposals.
  # Set to false if you do not want to use this feature
  config.allow_admins_to_hide_proposals =true

  # Public Setting that allows to configure which component will have "Use my location" button
  # in a geocoded address field. Accepts an array of component manifest names
  config.show_my_location_button = [:proposals, :meetings, :reporting_proposals]

  # Public Setting that adds a button next to the "add image" input[type=file] to open the camera directly
  config.use_camera_button = [:proposals, :reporting_proposals]

  # Public Setting to prevent adding the camera button on not photo/image input[type=file]
  config.camera_button_on_attachments = false

  # Public setting to prevent valuators or admins to modify the photos attached to a proposal
  # otherwise can be configured at the component level
  config.allow_proposal_photo_editing = true

  # Public setting to allow to assign other valuators
  config.valuators_assign_other_valuators = true
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/openpoke/decidim-module-reporting_proposals.

### Developing

To start contributing to this project, first:

- Install the basic dependencies (such as Ruby and PostgreSQL)
- Clone this repository

Decidim's main repository also provides a Docker configuration file if you
prefer to use Docker instead of installing the dependencies locally on your
machine.

You can create the development app by running the following commands after
cloning this project:

```bash
$ bundle
$ DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rake development_app
```

Note that the database user has to have rights to create and drop a database in
order to create the dummy test app database.

Then to test how the module works in Decidim, start the development server:

```bash
$ DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bin/rails s
```

Note that `bin/rails` is a convenient wrapper around the command `cd development_app; bundle exec rails`.

In case you are using [rbenv](https://github.com/rbenv/rbenv) and have the
[rbenv-vars](https://github.com/rbenv/rbenv-vars) plugin installed for it, you
can add the environment variables to the root directory of the project in a file
named `.rbenv-vars`. If these are defined for the environment, you can omit
defining these in the commands shown above.

#### Webpacker notes

As latests versions of Decidim, this repository uses Webpacker for Rails. This means that compilation
of assets is required everytime a Javascript or CSS file is modified. Usually, this happens
automatically, but in some cases (specially when actively changes that type of files) you want to 
speed up the process. 

To do that, start in a separate terminal than the one with `bin/rails s`, and BEFORE it, the following command:

```
bin/webpack-dev-server
```

#### Code Styling

Please follow the code styling defined by the different linters that ensure we
are all talking with the same language collaborating on the same project. This
project is set to follow the same rules that Decidim itself follows.

[Rubocop](https://rubocop.readthedocs.io/) linter is used for the Ruby language.

You can run the code styling checks by running the following commands from the
console:

```
$ bundle exec rubocop
```

To ease up following the style guide, you should install the plugin to your
favorite editor, such as:

- Atom - [linter-rubocop](https://atom.io/packages/linter-rubocop)
- Sublime Text - [Sublime RuboCop](https://github.com/pderichs/sublime_rubocop)
- Visual Studio Code - [Rubocop for Visual Studio Code](https://github.com/misogi/vscode-ruby-rubocop)

#### Non-Ruby Code Styling

There are other linters for Javascript and CSS. These run using NPM packages. You can
run the following commands:

1. `npm run lint`: Runs the linter for Javascript files.
2. `npm run lint-fix`: Automatically fix issues for Javascript files (if possible).
3. `npm run stylelint`: Runs the linter for SCSS files.
4. `npm run stylelint-fix`: Automatically fix issues for SCSS files (if possible).

### Testing

To run the tests run the following in the gem development path:

```bash
$ bundle
$ DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rake test_app
$ DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rspec
```

Note that the database user has to have rights to create and drop a database in
order to create the dummy test app database.

In case you are using [rbenv](https://github.com/rbenv/rbenv) and have the
[rbenv-vars](https://github.com/rbenv/rbenv-vars) plugin installed for it, you
can add these environment variables to the root directory of the project in a
file named `.rbenv-vars`. In this case, you can omit defining these in the
commands shown above.

### Test code coverage

If you want to generate the code coverage report for the tests, you can use
the `SIMPLECOV=1` environment variable in the rspec command as follows:

```bash
$ SIMPLECOV=1 bundle exec rspec
```

This will generate a folder named `coverage` in the project root which contains
the code coverage report.

### Localization

If you would like to see this module in your own language, you can help with its
translation at Crowdin:

https://crowdin.com/project/decidim-reporting_proposals

## License

See [LICENSE-AGPLv3.txt](LICENSE-AGPLv3.txt).
