class Mustache
  module Utils
    class String
      def initialize string
        @string = string
      end

      def classify
        @string.split('/').map do |namespace|
          namespace.split(/[-_]/).map do |part|
            part[0] = part.chars.first.upcase
            part
          end.join
        end.join('::')
      end

      def underscore(view_namespace)
        @string
          .dup
          .split("#{view_namespace}::")
          .last
          .split('::')
          .map do |part|
            part[0] = part[0].downcase
            part.gsub(/[A-Z]/) { |s| "_" << s.downcase }
          end
          .join('/')
      end
    end
  end
end
