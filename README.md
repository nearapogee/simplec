# Simplec

### A CMS for developers, built by developers.

This gem handles all of the rote parts of a CMS, but gets out of the way for
everything else. In Rails it is easy to build things from scratch, but it is
a waste of resources to build again and again. This library is an attempt to
get all of the good parts of a CMS without the baggage of a CMS that takes
over the entire ecosystem.

## Dependencies
- rails >= 5.0.5

- pg >= 0.21.0; postgres >= 9.5

  We hate dependencies, but postgres is just too good. We use it for search
  and JSONB.

- imagemagick

  For image processing.

- dragonfly

  We still hate dependencies, but this is a necessity and the best option.

## Recommended Dependencies

- summernote

  Used for editor fields. Source is included.

- bootstrap-sass >= 3.0.0

  Required if you want to use editor fields (which utilize summernote).

- jquery

  Hope to be able to remove this, but required for summernote/bootstrap for now.

**The recommended dependencies are only required for the admin portions of your
application.**

_Optionally, you can create a separate set of assets for only the admin via
standard Rails methods. Or you could not include them and deal with the
fallout. ;-)_


## Features
- Pages with Templates

- Subdomain support

- Use application models or assets in CMS pages

- Search (coming soon)

## Anti-Features
- User management

- Permissions

## Proposed auxilary gems

- simplec-vlad: The easiest way to deploy and manage an installation.
  Database and file syncs between enviroments.

- simplec-blog: Don't always need or want a blog bundled in. (You might have
  your own.)

- simplec-admin: Opinionated, prebuilt way of managing pages. Take it or leave
  it. Or don't mount it and generate scaffold controllers and views for basic
  functions.

- simplec-events

## Usage

1. Add to gemfile
2. Mount engine
3. Create pages and corresponding templates
4. Build, generator, or use an auxilary gem for page admin.
5. Let users loose.

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
    <h1>My Application</h1>
    <h2><%= @page.tagline %></h2>
    ```

5. And create a page in your admin.

6. Done.


## Installation

1. Add this line to your application's Gemfile:

    ```ruby
    gem 'pg'
    gem 'simplec'
    # plus optional gems
    ```

2. Mount the engine

    ```ruby
    Rails.application.routes.draw do
      mount Simplec::Engine => "/"
    end
    ```

## Roadmap
1. Remove as many dependencies as possible.

## Contributing
1. Use it and file create issues. Somethings are core, other things will be
  relegated to 3rd party extensions.
2. Pull requests are welcome. See rule #1.

## TODO
- Document `lib/simplec/controller_extensions.rb`

- Document why _subdomain in subdomain form in admin.

- rails generate simplec:install
  Install app/models/page.rb, app/models/page/
  initializer if needed, with options documented

- simplec_path/simplec_url caching

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

4. Install Dragonfly

        rails generate dragonfly

  Configure as required. Documentation is here: http://markevans.github.io/dragonfly/

5. Install Bootstrap

    ```ruby
    gem 'bootstrap-sass', "~> 3.3.7'
    ```

  Read the rest here: https://github.com/twbs/bootstrap-sass

6. Install imagemagick

  Varies per operating system.

## Contributors

- Matt Smith, Near Apogee Consulting (www.nearapogee.com)

- @lithxe, @jessedo81 for ongoing feedback, use cases, development support,
  and the initial project to test the concept.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
