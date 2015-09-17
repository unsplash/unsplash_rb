module Unsplash # :nodoc:

  # Unsplash Photo operations.
  class Photo < Client

    class << self

      # Get a photo. Can be cropped or resized using the optional parameters.
      # @param id [String] The ID of the photo to retrieve.
      # @param width [Integer] Width of customized version of the photo.
      # @param height [Integer] Height of the customized version of the photo.
      # @param crop_rect [String] A comma-separated list (x,y,width,height) of the rectangle to crop from the photo.
      # @return [Unsplash::Photo] The Unsplash Photo.
      def find(id, width: nil, height: nil, crop_rect: nil)
        custom = {
          w:    width,
          h:    height,
          rect: crop_rect
        }.select { |k,v| v }
        photo = Unsplash::Photo.new JSON.parse(connection.get("/photos/#{id}", custom).body)
        photo.user = Unsplash::User.new photo.user
        photo
      end

      # Get a random photo. The photo selection pool can be narrowed using
      # a combination of optional parameters. Can also optionally specify a custom image size.
      # @param categories [Array] Limit selection to given category ID's.
      # @param featured [Boolean] Limit selection to featured photos.
      # @param user [String] Limit selection to given User's ID.
      # @param query [String] Limit selection to given search query.
      # @param width [Integer] Width of customized version of the photo.
      # @param height [Integer] Height of the customized version of the photo.
      # @return [Unsplash::Photo] An Unsplash Photo.
      def random(categories: nil, featured: nil, user: nil, query: nil, width: nil, height: nil)
        params = {
          category: (categories && categories.join(",")),
          featured: featured,
          username: user,
          query:    query,
          w:        width,
          h:        height
        }.select { |k,v| v }

        photo = Unsplash::Photo.new JSON.parse(connection.get("/photos/random", params).body)
        photo.user = Unsplash::User.new photo.user
        photo
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
        photo = Unsplash::Photo.new JSON.parse(connection.post("/photos", photo: file).body)
        photo.user = Unsplash::User.new photo.user
        photo
      end

      private

      def parse_list(json)
        JSON.parse(json).map { |photo| new photo }
      end

    end
  end
end