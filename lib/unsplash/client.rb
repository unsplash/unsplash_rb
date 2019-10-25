module Unsplash # :nodoc:

  # Common functionality across Unsplash API objects.
  class Client

    # Build an Unsplash object with the given attributes.
    # @param attrs [Hash]
    def initialize(attrs = {})
      @attributes = OpenStruct.new(attrs)
      add_utm_to_links
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

    # Raw JSON as returned by Unsplash API.
    # @return [Hash] json
    def to_h
      @attributes.to_h
    end

    # @private
    def method_missing(method, *args, &block)
      attribute = @attributes.send(method, *args, &block)
      attribute.is_a?(Hash) ? Client.new(attribute) : attribute
    end

    # The connection object being used to communicate with Unsplash.
    # @return [Unsplash::Connection] the connection
    def connection
      self.class.connection
    end

    # @private
    def add_utm_params(url)
      uri = URI.parse(url)

      qs = Rack::Utils.parse_nested_query(uri.query)
      qs.merge!(connection.utm_params)

      uri.query = Rack::Utils.build_query(qs)

      uri.to_s
    end

    # @private
    def add_utm_to_links
      (@attributes["links"] || {}).each do |key, url|
        @attributes["links"][key] = add_utm_params(url)
      end
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
