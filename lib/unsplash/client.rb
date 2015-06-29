module Unsplash # :nodoc:

  # Common functionality across Unsplash API objects.
  class Client

    # Build an Unsplash object with the given attributes.
    # @param attrs [Hash] 
    def initialize(attrs = {})
      @attributes = OpenStruct.new(attrs)
    end

    # (Re)load full object details from Unsplash.
    # @return [Unspash::Client] Itself, with full details reloaded.
    def reload!
      if links && links["self"]
        attrs = JSON.parse(connection.get(links["self"]).body)
        @attributes = OpenStruct.new(attrs)
        self
      else
        raise Unsplash::Error.new "Missing self link for #{self.class} with ID #{self.id}"
      end
    end

    # @private
    def method_missing(method, *args, &block)
      @attributes.send(method, *args, &block)
    end

    # The connection object being used to communicate with Unsplash.
    # @return [Unsplash::Connection] the connection
    def connection
      self.class.connection
    end

    class << self 
      # The connection object being used to communicate with Unsplash.
      # @return [Unsplash::Connection] the connection
      def connection
        @@connection ||= Connection.new
      end

      # Assign a default connection object.
      # @param conn [Unsplash::Connection] the connection
      # @return [Unsplash::Connection] the connection
      def connection=(conn)
        @@connection = conn
      end
    end
  end
end