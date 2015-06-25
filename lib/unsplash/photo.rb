module Unsplash # :nodoc:

  # Unsplash Photo operations.
  class Photo < Model

    class << self

      # Get a user.
      # @param id [String] the ID of the photo to retrieve.
      # @return [Unsplash::Photo] the Unsplash Photo.
      def find(id)
        new JSON.parse(connection.get("/photos/#{id}").body)
      end

      # Search for photos by keyword.
      # @param query [String] Keywords to search for.
      # @param page  [Integer] Which page of search results to return.
      # @param per_page [Integer] The number of search results per page.
      def search(query, page = 1, per_page = 10)
        params = {
          query:    query,
          page:     page,
          per_page: per_page
        }
        parse_list connection.get("/photos/search/", params).body
      end

      # Get a list of all photos.
      # @param page  [Integer] Which page of search results to return.
      # @param per_page [Integer] The number of search results per page. 
      # @return [Array] A single page of +Unsplash::Photo+ search results.
      def all(page = 1, per_page = 10)
        params = {
          page:     page,
          per_page: per_page
        }
        parse_list connection.get("/photos/", params).body
      end

      # Upload a photo on behalf of the current user.
      # @param filepath [String] The local path of the image file to upload.
      # @return [Unsplash::Photo] The uploaded photo.
      def create(filepath)
        file = Faraday::UploadIO.new(filepath, "image/jpeg")
        new JSON.parse(connection.post("/photos", photo: file).body)
      end

      private

      def parse_list(json)
        JSON.parse(json).map { |photo| new photo }
      end

    end
  end
end