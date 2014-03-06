module Lotus
  module Routing
    class Path
      attr_reader :raw, :compiled

      def initialize(raw, options = {})
        @raw      = raw
        @compiled = _compile(raw.dup, options) unless fixed?
      end

      def fixed?
        variables.empty?
      end

      def _compile(raw, options)
        #FIXME remove this exceptions suppression once the refactoring will be done.
        begin
          optional_variables.each do |var|
            raw.gsub!(/#{ Regexp.escape(var) }/, _token(var, options))
            raw.chop!
          end

          mandatory_variables.each do |var|
            raw.gsub! var, _token(var, options)
          end

          /\A#{ raw }\z/
        rescue
          puts "Failed scan for #{ @raw }"
        end
      end

      private
      def variables
        (mandatory_variables + optional_variables).uniq
      end

      def mandatory_variables
        raw.scan(/[\.]*[:*][a-z0-9_]+/).flatten
      end

      def optional_variables
        raw.scan(/(?=\(((?:[^()]++|\(\g<1>\))++)\))/).flatten.map {|el| "(#{ el.gsub(/\((.*)\)\z/, '')}" }
      end

      def _token(var, options)
        _regexp(var, options[_variable_name(var)]).to_s
      end

      def _variable_name(string)
        string.gsub(/[\(\)\:\.\*\/]*/, '').to_sym
      end

      def _regexp(variable, regexp)
        if regexp
          %r{(?<#{ _variable_name(variable) }>#{ regexp })}
        else
          require 'byebug'
          byebug if variable.include?('world')
          case variable
          when /\A\*/
            /(?<#{ _variable_name(variable) }>(.*?))/
          when /\A\(\./
            /[\.]*(?<#{ _variable_name(variable) }>[a-z0-9_]*)/
          when /\A\(\//
            /[\/]*(?<#{ _variable_name(variable) }>[a-z0-9_]*)/
          when /\A\(/
            /(?<#{ _variable_name(variable) }>[a-z0-9_]*)/
          else
            /(?<#{ _variable_name(variable) }>[a-z0-9_]+)/
          end
        end
      end
    end
  end
end
