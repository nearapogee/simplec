# Simplec

### A CMS for developers, built by developers.

This gem handles all of the rote parts of a CMS, but gets out of the way for
everything else. In Rails it is easy to build things from scratch, but it is
a waste of resources to build again and again. This library is an attempt to
get all of the good parts of a CMS without the baggage of a CMS that takes
over the entire ecosystem.

## Features
- Pages with Templates

- Subdomains

- Use any application models, assets in CMS pages

- Search (future)

- Blog (future)

## Anti-Features
- User management

- Permissions

## Proposed auxilary gems

- simplec-vlad: The easiest way to deploy and manage an installation.
  Database and file syncs between enviroments.

- simplec-admin: Opinionated, prebuilt way of managing pages. Take it or leave
  it.

- simplec-admin-gen: Generate controllers and views (basically a scaffold) to
  be modified as you see fit.

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

## Contributing
1. Use it and file create issues. Somethings are core, other things will be
  relegated to 3rd party extensions.
2. Pull requests are welcome. See rule #1.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
