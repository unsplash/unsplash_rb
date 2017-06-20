module Unsplash # :nodoc:

  # Unsplash Search operations
  class Search < Client

    class << self
      # Helper class to facilitate search on multiple classes
      # @param url [String] Url to be searched into
      # @param klass [Class] Class to instantiate the contents with
      # @param params [Hash] Params for the search
      def search(url, klass, params)
        list = JSON.parse(connection.get(url, params).body)
        
        process_response(list, klass)
      end

      private

      def process_response(list, klass)
        result = {}
        result[:total] = list["total"]
        result[:total_pages] = list["total_pages"]
        result[:results] = create_objects(list["results"], klass)
        result
      end

      def create_objects(results, klass)
        results.map do |content|
          klass.new content.to_hash
        end
      end
    end
  end
end
