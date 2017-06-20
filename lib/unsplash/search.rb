module Unsplash # :nodoc:

  # Decorates Array of klass-type objects with total and total_pages attributes
  class SearchResult < SimpleDelegator
    attr_reader :total, :total_pages

    def initialize(decorated, klass)
      @total = decorated["total"]
      @total_pages = decorated["total_pages"]

      list = decorated["results"].map do |content|
        klass.new content.to_hash
      end

      super(list)
    end
  end

  # Unsplash Search operations
  class Search < Client

    class << self
      # Helper class to facilitate search on multiple classes
      # @param url [String] Url to be searched into
      # @param klass [Class] Class to instantiate the contents with
      # @param params [Hash] Params for the search
      # @return [SearchResult] Decorated Array of klass-type objects
      def search(url, klass, params)
        list = JSON.parse(connection.get(url, params).body)
        SearchResult.new(list, klass)
      end
    end
  end
end
