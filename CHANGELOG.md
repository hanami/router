# Lotus::Router
Rack compatible HTTP router for Ruby

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
