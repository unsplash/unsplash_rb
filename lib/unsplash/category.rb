module Unsplash # :nodoc:

  # Unsplash Category operations.
  class Category < Client

    class << self

      # Get a list of all of the Unsplash photo categories.
      # @return [Array] The list categories.
      # <b>DEPRECATED</b>
      def all
        raise Unsplash::DeprecationError.new "Category has been deprecated and removed."
      end

      # Get an Unsplash Category.
      # @param id [Integer] The ID of the category to retrieve.
      # @return [Unsplash::Category] The specified category.
      # <b>DEPRECATED</b>
      def find(id)
        raise Unsplash::DeprecationError.new "Category has been deprecated and removed."
      end
    end

    # Get a list of all photos in this category.
    # @param page  [Integer] Which page of search results to return.
    # @param per_page [Integer] The number of search results per page. 
    # @return [Array] A single page of +Unsplash::Photo+s.
    # <b>DEPRECATED</b>
    def photos(page = 1, per_page = 10)
      raise Unsplash::DeprecationError.new "Category has been deprecated and removed."
    end
  end
end
