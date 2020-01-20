# frozen_string_literal: true

require "rack/utils"
require "mustermann/rails"

module Hanami
  class Router
    # Route path
    #
    # @since x.x.x
    # @api private
    class Segment
      def self.fabricate(segment, **constraints)
        Mustermann.new(segment, type: :rails, version: "5.0", capture: constraints)
      end

      #       def initialize(segment, **constraints)
      #         @segment    = segment
      #         @expandable = segment
      #         @regexp     = expand_segment(segment, **constraints)
      #         freeze
      #       end

      #       def match(arg)
      #         @regexp.match(arg)
      #       end

      #       def expand(variables = {})
      #         vars = variables.dup

      #         result = @expandable.gsub(/({({)?)([[[:alnum:]]\_]+)(}(})?)/) do
      #           value = vars.delete(Regexp.last_match(3).to_sym)

      #           case Regexp.last_match(2)
      #           when NilClass
      #             value or raise "cannot interpolate"
      #             Rack::Utils.escape(value)
      #           else
      #             value
      #           end
      #         end

      #         result += ("?" + Rack::Utils.build_nested_query(vars)) unless vars.empty?
      #         result
      #       end

      #       def hash
      #         @segment.hash | @regexp.hash
      #       end

      #       def ==(other)
      #         other.class == self.class &&
      #           other.segment == segment &&
      #           other.regexp == regexp
      #       end

      #       alias === ==

      #       def eql?(other)
      #         other.class.eql?(self.class) &&
      #           other.segment.eql?(segment) &&
      #           other.regexp.eql?(regexp)
      #       end

      #       def inspect
      #         "#<#{self.class.name} #{@segment.inspect}>"
      #       end

      #       protected

      #       attr_reader :segment, :regexp

      #       private

      #       def expand_segment(segment, **constraints)
      #         expanded = segment.gsub(/[\$\+\?\.\(\)]{1}/) { |match| escape_ctrl(match) }
      #         expanded = expanded.gsub(/[[:space:]]+/) { |match| escape_space(match) }
      #         expanded = expanded.gsub(/:[[[:alnum:]]\_]*/) { |match| expand_variable(match, constraints) }
      #         expanded = expanded.gsub(/\P{ASCII}/) { |match| escape_char(match) }
      #         expanded = expanded.gsub(/\*[[[:alnum:]]\_]*/) { |match| expand_glob(match, constraints) }

      #         /\A(?-mix:#{expanded})\Z/
      #       end

      #       def escape_ctrl(ctrl)
      #         case ctrl
      #         when "."
      #           "(?:\\.|%2E|%2e)"
      #         when "("
      #           "(?:"
      #         when ")"
      #           ")?"
      #         else
      #           "\\#{ctrl}"
      #         end
      #       end

      #       def escape_space(*)
      #         "(?:%20|(?:\\+|%2b|%2B)| )"
      #       end

      #       def expand_variable(variable, **constraints)
      #         return variable if variable.match?(/\A\:\Z/) # FIXME: ":" variable shouldn't be passed here

      #         var = variable.sub(/\A\:/, "")
      #         @expandable = if (opt_var = optional_variable(variable))
      #                         @expandable.sub(opt_var.to_s, "{{#{opt_var.to_s.sub(variable, var)}}}")
      #                       else
      #                         @expandable.sub(variable, "{#{var}}")
      #                       end

      #         "(?<#{var}>#{escape_variable(var, constraints)})"
      #       end

      #       def escape_char(char)
      #         "(?:#{char}|#{Rack::Utils.escape_path(char)})"
      #       end

      #       def expand_glob(glob, **_constraints)
      #         g = glob.sub(/\A\*/, "")
      #         @expandable = @expandable.sub(glob, "(#{g})")

      #         "(?<#{g}>.*?)"
      #       end
      #         content = constraints.fetch(var.to_sym, nil)

      #         case content
      #         when Regexp
      #           "[#{content.source.sub(/\\/, '\\')}]+?"
      #         when NilClass
      #           "[^\/\\?#]+?"
      #         when Array
      #           "(#{content.join('|')})+?"
      #         else
      #           "(#{Regexp.escape(content.to_s)})+?"
      #         end
      #       end

      #       def optional_variable(variable)
      #         @segment.match(/\(.*#{variable}?\)/)
      #       end
    end
  end
end
