# Simplec

### A CMS that stays out of the way.

This gem handles all of the rote parts of a CMS, but gets out of the way for everything else.

In Rails it is easy to build things from scratch, but it is a waste of resources
to build again and again. This library is an attempt to get all of the good
parts of a CMS without the baggage of a CMS that takes over the entire
ecosystem.

## Dependencies

- rails >= 5.1.0

    If you want to use this with earlier versions of rails, please create a
    github issue.

- pg >= 0.21.0; Postgres >= 9.5

    We hate dependencies, but Postgres is just too good. We use it for search
    and JSONB. If you think we could make this database agnostic, we are open
    for contributions!

- dragonfly

    We still hate dependencies, but this is a necessity and one of the best
    options. We might change it out for ActiveStorage.

- imagemagick

    For image processing.

## Recommended Dependencies

- summernote

    Used for editor fields. Source is included.

- bootstrap-sass >= 3.0.0

    Required if you want to use editor fields (which utilize summernote).

- jquery-rails

    Hope to be able to remove this, but required for summernote/bootstrap for now.

**The recommended dependencies are only required for the admin portions of your
application.**

_Optionally, you can create a separate set of assets for only the admin via
standard Rails methods. Or you could not include them and deal with the
fallout. We are happy to accept pull requests! ;-)_


## Features

- Pages with Templates

- Subdomain support

- Search (coming soon)

- Documents and Document Sets (local or S3/Google/etc)

- Use application models or assets in CMS pages

## Anti-Features

- User management

- Permissions

## Proposed auxilary gems

- simplec-vlad: The easiest way to deploy and manage an installation.
  Database and file syncs between enviroments.

- simplec-blog: Don't always need or want a blog bundled in. (You might have
  your own.)

- simplec-sections: Sections compose pages. Configure pages composed of Sections
  rather than taking a page hook line and sinker.

- simplec-admin: Opinionated, prebuilt way of managing pages. Take it or leave
  it. Or don't mount it and generate scaffold controllers and views for basic
  functions.

- simplec-events

## Usage

'www' is considered the default subdomain.

'admin' subdomain is reserved for administration functions if you wish.

If you want to modify all pages you should edit ::Page < Simplec::Page, this
will be generated in an installer later.

If you want to test a subclass of ::Page, make sure test has ::Page defined.

Create a public layout. The public layout is the default. This will be
generated in an installer later.

Put page model definitions in `app/models/page/`.

Put model templates in `app/views/pages/`. AND prefix with an underscore (_),
i.e. `_home.html.erb`.

TODO override field types howto

TODO explain using uuids for keys + pgcrypto

TODO explain how to augment model classes (example in `test/dummy/config/initializers/simplec.rb`)

### Steps

1. Install simplec in your Rails application.

    See installation section.

2. Build and admin interface with the rest of your application.

    Simplec doesn't tell you how to do this. Currently, you should look at the
    test/dummy application for inspiration.

3. Then define a model:

    ```ruby
    # app/models/page/home.rb
    class Page::Home < ::Page
      field :tagline
    end
    ```

4. And the corresponding template:

    ```erb
    <!-- app/views/pages/_home.html.erb -->
    <h1>My Application</h1>
    <h2><%= @page.tagline %></h2>
    ```

    Note: You need to call `#html_safe` on fields with `type: :editor`.

5. And create a page in your admin.

6. Done.


## Installation

1. Add this line to your application's Gemfile:

    ```ruby
    gem 'pg'
    gem 'simplec'
    # plus optional gems
    ```

    At this point it is assumed you are integrating Simplec into an existing
    application, logically then you have your database already configured.
    However, Simplec requires some postgres configuration. Please read the
    section below on Postgres.

2. Install and run the migrations

    ```shell
    rake simplec:install:migrations
    rake db:migrate
    ```

3. Mount the engine

    ```ruby
    Rails.application.routes.draw do
      mount Simplec::Engine => "/"
    end
    ```

4. Install and configure `dragonfly`

    ```shell
    rails generate dragonfly
    ```

    Then configure `config/initializers/dragonfly.rb`.

    It is recommended to use `rack/cache` or some other HTTP caching solution.

5. Optional - Install bootstap-sass.

    ```ruby
    gem 'bootstrap-sass', "~> 3.3.7'
    ```

    Currenty, we have worked out integration with Bootstrap > 3 and are waiting
    for the dust to settle on V4. See directions here:
    https://github.com/twbs/bootstrap-sass

6. Optional - If you want to use the bundled summernote:

    Load the JS in your application's manifest.

    ```javascript
    //= require simplec/summernote
    //= require simplec/summernote-config
    ```

    Please note that this needs to be loaded after jquery and bootstrap.

    ```css
    @import "simplec/summernote";
    ```

    Please note that this needs to be loaded after bootstrap. And to use
    `@import` statements, you must use `.scss` files.

## Postgres

Note you will need to do this in your production environment as well. 

On some operating systems, `pgcrypto` is in a separate `postgres` package,
be sure to install that as well.

The `pgcrypto` extension is required for the `gen_random_uuid()` function
used to generate uuid primary keys.

1. Create your application postgres user (matching database.yml)

    ```shell
    # -s for superuser in development
    createuser -s myapp
    ```

2. Create databases and add pgcrypto

    ```shell
    # create development/test databases
    rake db:create

    # required for gen_random_uuid() function
    # used for ids in Simplec models
    #
    psql myapp_development -c "CREATE EXTENSION pgcrypto;"
    psql myapp_test -c "CREATE EXTENSION pgcrypto;"
    ```

## imagemagick

Installation varies per operating system. Image magic is used by dragonfly
for on the fly (then cached) image manipulation.

Note there is a known vulnerability, please update accordingly: https://imagetragick.com/

See this page for a good cheat sheet: http://markevans.github.io/dragonfly/imagemagick

## Roadmap

1. TODOS:

    - Check doc view helpers

    - Add config options for uuid vs integer ids, maybe check if page is using
      uuid/id if table exists to determine going forward. Add note in README

    - Throw clear warning when creating a page without a type

    - main_app document or method_missing

    - Document `lib/simplec/controller_extensions.rb`

    - Document why _subdomain in subdomain form in admin.

    - rails generate simplec:install
      Install app/models/page.rb, app/models/page/
      initializer if needed, with options documented

    - rewrite beginning part of usage

    - utilize thread local variable for found subdomain in #subdomain

    - page previews?

    - configure uuid or integer pk/fk

    - note about migration versions on old rails installs

1. Sitemap

1. Installer `rails generater simplec:install`

1. Upgrade summernote from 0.8.2 to 0.8.6

1. Search

1. Caching

1. Optional Gems

1. Remove as many dependencies as possible.

1. github-markdown for markup?

## Contributing
1. Use it and file create issues. Somethings are core, other things will be
  relegated to 3rd party extensions.
2. Pull requests are welcome. See rule #1.

## Running dummy application

1. Create simplec postgres user

        # -s for superuser in development
        createuser -s simplec

2. Create databases and add pgcrypto

        rake db:create

        # required for gen_random_uuid() function
        # used for ids in Simplec models
        #
        psql simplec_development -c "CREATE EXTENSION pgcrypto;"

3. Migrate database

        rake db:migrate

4. Run the documentation server

        gem install yard
        yard server -r --no-cache --no-save --verbose --debug --backtrace

## Moving Backwards

- Depends on 5.1.x because of on_load hooks, specifically
  :action_controller_base. Could be moved back, but need to figure out
  equivalent ways of loading in the engine.

## Contributors

- Matt Smith, Near Apogee Consulting (www.nearapogee.com)

- @lithxe, @jessedo81 for ongoing feedback, use cases, development support,
  and the initial project to test the concept.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
