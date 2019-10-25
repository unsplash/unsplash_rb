module Unsplash # :nodoc:

  # Unsplash Photo operations.
  class Photo < Client

    def initialize(attrs)
      super
      add_utm_to_urls
    end

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

    # Track the download of a photo.
    # @return [String] URL of image file for download.
    def track_download
      connection.get(links.download_location)["url"]
    end

    def add_utm_to_urls
      (@attributes["urls"] || {}).each do |key, url|
        @attributes["urls"][key] = add_utm_params(url)
      end
    end

    class << self

      # Get a photo. Can be cropped or resized using the optional parameters.
      # @param id [String] The ID of the photo to retrieve.
      # @return [Unsplash::Photo] The Unsplash Photo.
      def find(id)
        photo = Unsplash::Photo.new JSON.parse(connection.get("/photos/#{id}").body)
        photo.user = Unsplash::User.new photo.user
        photo
      end

      # Get a random photo or set of photos. The photo selection pool can be narrowed using
      # a combination of optional parameters.
      # @param count [Integer] Number of photos required. Default=1, Max=30
      # @param featured [Boolean] Limit selection to featured photos.
      # @param user [String] Limit selection to given User's ID.
      # @param query [String] Limit selection to given search query.
      # @param orientation [String] Filter by orientation of the photo. Valid values are landscape, portrait, and squarish.
      # @return [Unsplash::Photo] An Unsplash Photo if count parameter is omitted
      # @return [Array] An array of Unsplash Photos if the count parameter is specified. An array is returned even if count is 1
      def random(count: nil, collections: nil, featured: nil, user: nil, query: nil, orientation: nil)
        Unsplash.configuration.logger.warn "You cannot combine 'collections' and 'query' parameters. 'query' will be ignored." if collections && query

        params = {
          collections: (collections && collections.join(",")),
          featured: featured,
          username: user,
          query:    query,
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

      private

      def parse_list(json)
        JSON.parse(json).map { |photo| new photo }
      end
    end
  end
end
