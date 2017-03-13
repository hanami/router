# coding: utf-8
#
# This monkey patches http_router to make it Rack 2.0 compatible.
# Details see: https://github.com/hanami/router/issues/136
#
# @api private
class HttpRouter
  # @api private
  class Node
    # @api private
    class Path < Node
      def to_code
        path_ivar = inject_root_ivar(self)
        "#{"if !callback && request.path.size == 1 && request.path.first == '' && (request.rack_request.head? || request.rack_request.get?) && request.rack_request.path_info[-1] == ?/
          response = ::Rack::Response.new
          response.redirect(request.rack_request.path_info[0, request.rack_request.path_info.size - 1], 302)
          return response.finish
        end" if router.redirect_trailing_slash?}

        #{"if request.#{router.ignore_trailing_slash? ? 'path_finished?' : 'path.empty?'}" unless route.match_partially}
          if callback
            request.called = true
            callback.call(Response.new(request, #{path_ivar}))
          else
            env = request.rack_request.env
            env['router.request'] = request
            env['router.params'] ||= {}
            #{"env['router.params'].merge!(Hash[#{param_names.inspect}.zip(request.params)])" if dynamic?}
            @router.rewrite#{"_partial" if route.match_partially}_path_info(env, request)
            response = @router.process_destination_path(#{path_ivar}, env)
            return response unless router.pass_on_response(response)
          end
        #{"end" unless route.match_partially}"
      end

    end
  end
end
