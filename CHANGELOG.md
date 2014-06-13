## v0.1.1
### Jun 23, 2014

6f0ea8b 2014-06-12 **Luca Guidi** Introduced Lotus::Router#mount
8457e1c 2014-06-08 **Luca Guidi** Use composition over inheritance for Lotus::Routing::Resource::Options
9426099 2014-05-13 **Luca Guidi** Let specify a pattern for Lotus::Routing::EndpointResolver
340ce17 2014-05-10 **Luca Guidi** Enable Ruby 2.1.2 on Travis CI
42b83b8 2014-02-24 **Luca Guidi** Added support for Ruby 2.1.1
6a5daf9 2014-02-15 **Luca Guidi** Make Lotus::Routing::Endpoint::EndpointNotFound to inherit from StandardError, instead of Exception. This make it compatible with Rack::ShowExceptions.

## v0.1.0
### Jan 23, 2014

594e332 2014-01-23 **Luca Guidi** Added support for OPTIONS HTTP verb
10af04b 2014-01-17 **Luca Guidi** Added Lotus::Routing::EndpointNotFound when a lazy endpoint can't be found
72165e5 2014-01-17 **Luca Guidi** Make action separator customizable via Lotus::Router options.
ca7ea8d 2014-01-17 **Luca Guidi** Catch http_router exceptions and re-raise them with names under Lotus::Routing. This helps to have a stable public API.
3d678e3 2014-01-16 **Luca Guidi** Lotus::Router now encapsulates Lotus::Routing::HttpRouter, instead of directly inherit from HttpRouter. This will protect our public API against HttpRouter changes.
8e8f7f9 2014-01-16 **Luca Guidi** Lotus::Routing::Resource::CollectionAction use configurable controller and action name separator over the hardcoded value
0bc8e54 2014-01-10 **Luca Guidi** Implemented Lotus::Routing::Namespace#resource
e134e5c 2014-01-08 **Luca Guidi** Simplify Lotus::Router public API: removed .draw and let .new to accept a block
815391a 2014-01-07 **Luca Guidi** When resetting the router, allow the default values for scheme, host and port to be reinitialized as http_router does
bc763a8 2013-08-07 **Luca Guidi** Lotus::Routing::EndpointResolver now accepts options to inject namespace and suffix
153047f 2013-08-07 **Luca Guidi** Allow resolver and route class to be injected via options. Added options argument to .draw
cd1128f 2013-08-07 **Luca Guidi** Lotus::EndpointResolver => Lotus::Routing::EndpointResolver
96a67c1 2013-07-09 **Luca Guidi** Return 404 for not found and 405 for unacceptable HTTP method
7450883 2013-07-05 **Luca Guidi** Allow non-finished Rack responses to be used
aa92524 2013-06-24 **Luca Guidi** Ensure .draw to always return a Lotus::Router instance
30029af 2013-06-22 **Luca Guidi** Implemented lazy loading for endpoints
962fbdf 2013-06-21 **Luca Guidi** Implemented Lotus::Router.draw
982d95a 2013-06-20 **Luca Guidi** Gemified
bac478a 2013-06-20 **Luca Guidi** Massive cleanup
aaf46a1 2013-06-20 **Luca Guidi** Add support for resource
41ee67d 2013-06-20 **Luca Guidi** Drastically reduced LOCs :heart_eyes:
6b245bf 2013-06-19 **Luca Guidi** Support for resource's member and collection
727e997 2013-06-19 **Luca Guidi** Add support for namespaces
4950777 2013-06-18 **Luca Guidi** Added support for RESTful resources
c494c85 2013-06-18 **Luca Guidi** Add support for POST, DELETE, PUT, PATCH, TRACE
71fb4a1 2013-06-17 **Luca Guidi** Routes constraints
86d696a 2013-06-17 **Luca Guidi** Named urls
423cf2c 2013-06-17 **Luca Guidi** Ensure redirect works properly
1ee662a 2013-06-17 **Luca Guidi** Run all the test suite
e2382a0 2013-06-16 **Luca Guidi** Add support for Procs:
f397aac 2013-06-16 **Luca Guidi** Implemented redirect
dded0c5 2013-06-14 **Luca Guidi** Initial mess
