# Hanami::Router
Rack compatible HTTP router for Ruby

## v0.7.0 - (unreleased)
### Added
- [Sean Collins] Introduced `Hanami::Router#root`. Example: `root to: 'home#index'`, equivalent to `get '/', to: 'home#index', as: :root`.
- [Nicola Racco] Allow to mount Rack applications at a specific host. Example: `mount Blog, host: 'blog'`, which will be hit for `GET http://blog.example.com`
- [Luca Guidi] Support `multi_json` gem as backend for JSON body parser. If `multi_json` is present in the gem bundle, it will be used, otherwise it will fallback to Ruby's `JSON`.
- [Luca Guidi] Introduced `Hanami::Routing::RecognizedRoute#path` in order to allow a better introspection

### Fixed
- [Andrew De Ponte] Make routes inspection to work when non-Hanami apps are mounted
- [Andrew De Ponte] Ensure to set the right `SCRIPT_NAME` in Rack env for mounted Hanami apps
- [Luca Guidi] Fix `NoMethodError` when `Hanami::Router#recognize` is invoked with a Rack env or a route name or a path that can't be recognized

### Changed
– [Luca Guidi] Drop support for Ruby 2.0 and 2.1. Official support for JRuby 9.0.5.0+

## v0.6.2 - 2016-02-05
### Fixed
- [Anton Davydov] Fix double leading slash for Capybara's `current_path`

## v0.6.1 - 2016-01-27
### Fixed
- [Luca Guidi] Fix body parsers for non Hash requests

## v0.6.0 - 2016-01-22
### Changed
- [Luca Guidi] Renamed the project

## v0.5.1 - 2016-01-19
- [Anton Davydov] Print stacked lines for routes inspection

## v0.5.0 - 2016-01-12
### Added
- [Luca Guidi] Added `Lotus::Router#recognize` as a testing facility. Example `router.recognize('/') # => associated route`
- [Luca Guidi] Added `Lotus::Router.define` in order to wrap routes definitions in `config/routes.rb` when `Lotus::Router` is used outside of Lotus projects
- [David Strauß] Make `Lotus::Routing::Parsing::JsonParser` compatible with `application/vnd.api+json` MIME Type
- [Alfonso Uceda Pompa] Improved exception messages for `Lotus::Router#path` and `#url`

### Fixed
- [Alfonso Uceda Pompa] Ensure `Lotus::Router#path` and `#url` to generate correct URL for mounted applications
- [Vladislav Zarakovsky] Ensure Force SSL mode to respect Rack SPEC

### Changed
- [Alfonso Uceda Pompa] A failure for body parsers raises a `Lotus::Routing::Parsing::BodyParsingError` exception
- [Karim Tarek] Introduced `Lotus::Router::Error` and let all the framework exceptions to inherit from it.

## v0.4.3 - 2015-09-30
### Added
- [Luca Guidi] Official support for JRuby 9k+

## v0.4.2 - 2015-07-10
### Fixed
- [Alfonso Uceda Pompa] Ensure mounted applications to not repeat their prefix (eg `/admin/admin`)
- [Thiago Felippe] Ensure router inspector properly prints routes with repeated entries (eg `/admin/dashboard/admin`)

## v0.4.1 - 2015-06-23
### Added
- [Alfonso Uceda Pompa] Force SSL (eg `Lotus::Router.new(force_ssl: true`).
- [Alfonso Uceda Pompa] Allow router to accept a `:prefix` option, in order to generate prefixed routes.

## v0.4.0 - 2015-05-15
### Added
- [Alfonso Uceda Pompa] Nested RESTful resource(s)

### Changed
- [Alfonso Uceda Pompa] RESTful resource(s) have a correct pluralization/singularization for variables and named routes (eg. `/books/:id` is now `:book` instead of `:books`)

## v0.3.0 - 2015-03-23

## v0.2.1 - 2015-01-30
### Added
- [Alfonso Uceda Pompa] Lotus::Action compat: invoke `.call` if defined, otherwise fall back to `#call`.

## v0.2.0 - 2014-12-23
### Added
- [Luca Guidi & Alfonso Uceda Pompa] Introduced routes inspector for CLI
- [Luca Guidi & Janko Marohnić] Introduced body parser for JSON
- [Luca Guidi] Introduced request body parsers: they parse body and turn into params.
- [Fred Wu] Introduced Router#define

### Fixed
- [Luca Guidi] Fix for member/collection actions in RESTful resource(s): allow to take actions with a leading slash.
- [Janko Marohnić] Fix for nested namespaces and RESTful resource(s) under namespace. They were generating wrong route names.
- [Luca Guidi] Made InvalidRouteException to inherit from StandardError so it can be catched from anonymous `rescue` clause
- [Luca Guidi] Fix RESTful resource(s) to respect :only/:except options

### Changed
- [Luca Guidi] Aligned naming conventions with Lotus::Controller: no more BooksController::Index. Use Books::Index instead.
- [Luca Guidi] Removed `:prefix` option for routes. Use `#namespace` blocks instead.
- [Janko Marohnić] Make 301 the default redirect status

## v0.1.1 - 2014-06-23
### Added
- [Luca Guidi] Introduced Lotus::Router#mount
- [Luca Guidi] Let specify a pattern for Lotus::Routing::EndpointResolver
- [Luca Guidi] Make Lotus::Routing::Endpoint::EndpointNotFound to inherit from StandardError, instead of Exception. This make it compatible with Rack::ShowExceptions.

## v0.1.0 - 2014-01-23
### Added
- [Luca Guidi] Official support for Ruby 2.1
- [Luca Guidi] Added support for OPTIONS HTTP verb
- [Luca Guidi] Added Lotus::Routing::EndpointNotFound when a lazy endpoint can't be found
- [Luca Guidi] Make action separator customizable via Lotus::Router options.
- [Luca Guidi] Catch http_router exceptions and re-raise them with names under Lotus::Routing. This helps to have a stable public API.
- [Luca Guidi] Lotus::Routing::Resource::CollectionAction use configurable controller and action name separator over the hardcoded value
- [Luca Guidi] Implemented Lotus::Routing::Namespace#resource
- [Luca Guidi] Lotus::Routing::EndpointResolver now accepts options to inject namespace and suffix
- [Luca Guidi] Allow resolver and route class to be injected via options
- [Luca Guidi] Return 404 for not found and 405 for unacceptable HTTP method
- [Luca Guidi] Allow non-finished Rack responses to be used
- [Luca Guidi] Implemented lazy loading for endpoints
- [Luca Guidi] Implemented Lotus::Router.new to take a block and define routes
- [Luca Guidi] Add support for resource
- [Luca Guidi] Support for resource's member and collection
- [Luca Guidi] Add support for namespaces
- [Luca Guidi] Added support for RESTful resources
- [Luca Guidi] Add support for POST, DELETE, PUT, PATCH, TRACE
- [Luca Guidi] Routes constraints
- [Luca Guidi] Named urls
- [Luca Guidi] Added support for Procs as endpoints
- [Luca Guidi] Implemented redirect
- [Luca Guidi] Basic routing
