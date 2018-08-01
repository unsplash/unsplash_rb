module Unsplash # :nodoc:

  # Unsplash Photo operations.
  class Photo < Client

    # Like a photo for the current user.
    # @return [Boolean] True if successful. Will raise on error.
    def like!
      connection.post("/photos/#{id}/like")
      true
    end

    # Unlike a photo for the current user.
    # @return [Boolean] True if successful. Will raise on error.
    def unlike!
      connection.delete("/photos/#{id}/like")
      true
    end

    # Download a photo.
    # @return [String] URL of image file for download.
    def download!
      connection.get(links.download_location)["url"]
    end

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

      # Get a random photo or set of photos. The photo selection pool can be narrowed using
      # a combination of optional parameters. Can also optionally specify a custom image size.
      # @param count [Integer] Number of photos required. Default=1, Max=30
      # @param categories [Array] Limit selection to given category ID's.
      # @param featured [Boolean] Limit selection to featured photos.
      # @param user [String] Limit selection to given User's ID.
      # @param query [String] Limit selection to given search query.
      # @param width [Integer] Width of customized version of the photo.
      # @param height [Integer] Height of the customized version of the photo.
      # @param orientation [String] Filter by orientation of the photo. Valid values are landscape, portrait, and squarish.
      # @return [Unsplash::Photo] An Unsplash Photo if count parameter is omitted
      # @return [Array] An array of Unsplash Photos if the count parameter is specified. An array is returned even if count is 1
      def random(count: nil, categories: nil, collections: nil, featured: nil, user: nil, query: nil, width: nil, height: nil, orientation: nil)
        params = {
          category: (categories && categories.join(",")),
          collections: (collections && collections.join(",")),
          featured: featured,
          username: user,
          query:    query,
          w:        width,
          h:        height,
          orientation: orientation
        }.select { |k,v| v }
        if count
          params[:count] = count
          photos = parse_list connection.get("/photos/random/", params).body
          photos.map { |photo|
            photo.user = Unsplash::User.new photo[:user]
            photo
          }
        else
          photo = Unsplash::Photo.new JSON.parse(connection.get("/photos/random", params).body)
          photo.user = Unsplash::User.new photo.user
          photo
        end
      end

      # Search for photos by keyword.
      # @param query [String] Keywords to search for.
      # @param page  [Integer] Which page of search results to return.
      # @param per_page [Integer] The number of users search result per page. (default: 10, maximum: 30)
      # @param orientation [String] Filter by orientation of the photo. Valid values are landscape, portrait, and squarish.
      # @return [SearchResult] a list of +Unsplash::Photo+ objects.
      def search(query, page = 1, per_page = 10, orientation = nil)
        params = {
          query:    query,
          page:     page,
          per_page: per_page,
          orientation: orientation
        }.select { |_k, v| v }
        Unsplash::Search.search("/search/photos", self, params)
      end

      # Get a list of all photos.
      # @param page  [Integer] Which page of search results to return.
      # @param per_page [Integer] The number of search results per page. (default: 10, maximum: 30)
      # @param order_by [String] How to sort the photos. (Valid values: latest, oldest, popular; default: latest)
      # @return [Array] A single page of +Unsplash::Photo+ search results.
      def all(page = 1, per_page = 10, order_by = "latest")
        params = {
          page:     page,
          per_page: per_page,
          order_by: order_by
        }
        parse_list connection.get("/photos/", params).body
      end

      # Get a single page from the list of the curated photos (front-page’s photos).
      # @param page [Integer] Which page of search results to return.
      # @param per_page [Integer] The number of search results per page. (default: 10, maximum: 30)
      # @param order_by [String] How to sort the photos. (Valid values: latest, oldest, popular; default: latest)
      # @return [Array] A single page of +Unsplash::Photo+ search results.
      def curated(page = 1, per_page = 10, order_by = "latest")
        params = {
          page:     page,
          per_page: per_page,
          order_by: order_by
        }
        parse_list connection.get("/photos/curated", params).body
      end

      # Upload a photo on behalf of the current user.
      # @param filepath [String] The local path of the image file to upload.
      # @return [Unsplash::Photo] The uploaded photo.
      # <b>DEPRECATED</b>
      def create(filepath)
        raise Unsplash::Error.new "API photo-upload endpoint has been deprecated and removed."
      end

      private

      def parse_list(json)
        JSON.parse(json).map { |photo| new photo }
      end

    end
  end
end
