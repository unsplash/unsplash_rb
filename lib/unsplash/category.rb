module Unsplash # :nodoc:

  # Unsplash Category operations.
  class Category < Client

    class << self

      # Get a list of all of the Unsplash photo categories.
      # @return [Array] The list categories.
      def all
        JSON.parse(connection.get("/categories/").body).map do |category|
          new category
        end
      end

      # Get an Unsplash Category.
      # @param id [Integer] The ID of the category to retrieve.
      # @return [Unsplash::Category] The specified category.
      def find(id)
        new JSON.parse(connection.get("/categories/#{id}").body)
      end
    end

    # Get a list of all photos in this category.
    # @param page  [Integer] Which page of search results to return.
    # @param per_page [Integer] The number of search results per page. 
    # @return [Array] A single page of +Unsplash::Photo+s.
    def photos(page = 1, per_page = 10)
      params = {
        page:     page,
        per_page: per_page
      }
      list = JSON.parse(connection.get("/categories/#{id}/photos", params).body)
      list.map { |photo| Unsplash::Photo.new photo }
    end
  end
end