module Unsplash
  class Model

    def initialize(attrs = {})
      @attributes = OpenStruct.new(attrs)
    end

    def method_missing(method, *args, &block)
      @attributes.send(method, *args, &block)
    end

    def connection
      self.class.connection
    end

    class << self 
      def connection
        @@connection ||= Connection.new
      end

      def connection=(conn)
        @@connection = conn
      end
    end
  end
end