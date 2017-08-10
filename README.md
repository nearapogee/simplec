# Simplec

### A CMS for developers, built by developers.

This gem handles all of the rote parts of a CMS, but gets out of the way for
everything else. In Rails it is easy to build things from scratch, but it is
a waste of resources to build again and again. This library is an attempt to
get all of the good parts of a CMS without the baggage of a CMS that takes
over the entire ecosystem.

## Dependencies
- rails >= 5.0.5

- pg, postgres >= 9.5
  We hate dependencies, but postgres is just too good.

- imagemagick
  For image processing.

- dragonfly
  We still hate dependencies, but this is a necessity and the best option.

- summernote
  We still hate dependencies, but this is a necessity and the best option.
  _Only required on admin side of things -- a small consolation._

- bootstrap
  Really don't want this, but a dependency of summernote for now.
  _Only required on admin side of things -- a small consolation._

- jquery
  Hope to be able to remove this, but required for summernote/bootstrap for now.
  _Only required on admin side of things -- a small consolation._

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
  it.

- simplec-admin-gen: Generate controllers and views (basically a scaffold) to
  be modified as you see fit.

- simplec-events

## Usage

1. Add to gemfile
2. Mount engine
3. Create pages and corresponding templates
4. Build, generator, or use an auxilary gem for page admin.
5. Let users loose.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'pg'
gem 'simplec'
```

## Roadmap
1. Remove as many dependencies as possible.

## Contributing
1. Use it and file create issues. Somethings are core, other things will be
  relegated to 3rd party extensions.
2. Pull requests are welcome. See rule #1.

## Contributors

- Matt Smith, Near Apogee Consulting (www.nearapogee.com)

- @lithxe, @jessedo81 for ongoing feedback, use cases, development support,
  and the initial project to test the concept.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
