module Unsplash # :nodoc: 

  # Unsplash Collection operations.
  class Collection < Client

    class << self

      # Get a specific collection.
      # @param id [Integer] The ID of the collection.
      # @return [Unsplash::Collection] The requested collection.
      def find(id, curated = false)
        url = ["/collections", (curated ? "curated" : nil), id].compact.join("/")
        Unsplash::Collection.new JSON.parse(connection.get(url).body)
      end

      # Get a list of all collections.
      # @param page [Integer] Which page of search results to return.
      # @param per_page [Integer] The number of search results per page.
      # @return [Array] A single page of the +Unsplash::Collection+ list.
      def all(page = 1, per_page = 10)
        params = {
          page:     page,
          per_page: per_page
        }
        list = JSON.parse(connection.get("/collections/", params).body)
        list.map { |data| Unsplash::Collection.new(data) }
      end

      # Get a list of all curated collections.
      # @param page [Integer] Which page of search results to return.
      # @param per_page [Integer] The number of search results per page.
      # @return [Array] A single page of the +Unsplash::Collection+ list.
      def curated(page = 1, per_page = 10)
        params = {
          page:     page,
          per_page: per_page
        }
        list = JSON.parse(connection.get("/collections/curated", params).body)
        list.map { |data| Unsplash::Collection.new(data) }
      end

      # Create a new collection on behalf of current user.
      # @param title [String] The title of the collection.
      # @param description [String] The collection's description. (optional)
      # @param private [Boolean] Whether to make the collection private. (optional, default +false+)
      def create(title: "", description: "", private: false)
        params = { 
          title:       title,
          description: description,
          private:     private
        }
        Unsplash::Collection.new JSON.parse(connection.post("/collections", params).body)
      end

      # Get a single page of collection results for a query.
      # @param query [String] Keywords to search for.
      # @param page  [Integer] Which page of search results to return.
      # @return [Array] a list of +Unsplash::Collection+ objects. 
      def search(query, page = 1)
        params = {
          query:    query,
          page:     page
        }
        Unsplash::Search.search("/search/collections", self, params)
      end

    end

    def initialize(options = {})
      options["user"] = Unsplash::User.new options["user"]
      options["cover_photo"] = Unsplash::Photo.new options["cover_photo"]
      super(options)
    end

    # Update the collection's attributes.
    # @param title [String] The title of the collection.
    # @param description [String] The collection's description. (optional)
    # @param private [Boolean] Whether to make the collection private. (optional)
    def update(title: nil, description: nil, private: nil)
      params = { 
        title:       title,
        description: description,
        private:     private
      }.select { |k,v| v }
      updated = JSON.parse(connection.put("/collections/#{id}", params).body)
      self.title = updated["title"]
      self.description = updated["description"]
      self
    end

    # Delete the collection. This does not delete the photos it contains.
    # @return [Boolean] +true+ on success.
    def destroy
      response = connection.delete("/collections/#{id}")
      response.status == 204
    end

    # Get a list of the photos contained in this collection.
    # @return [Array] The list of +Unsplash::Photo+s in the collection.
    def photos(page = 1, per_page = 10)
      params = {
        page: page,
        per_page: per_page
      }

      list = JSON.parse(connection.get("/collections/#{id}/photos", params).body)
      list.map { |photo| Unsplash::Photo.new photo }
    end

    # Add a photo to the collection. If the photo is already in the collection,
    # this action has no effect.
    # @param [Unsplash::Photo] The photo to add.
    # @return [Hash] Collected photo metadata.
    def add(photo)
      response = JSON.parse(connection.post("/collections/#{id}/add", { photo_id: photo.id }).body)
      {
        photo_id:      response["photo"]["id"],
        collection_id: response["collection"]["id"],
        user_id:       response["user"]["id"],
        created_at:    response["created_at"]
      }
    end

    # Remove a photo from the collection. If the photo is not in the collection,
    # this action has no effect.
    # @param [Unsplash::Photo] The photo to remove.
    # @return [Boolean] +true+ on success.
    def remove(photo)
      response = connection.delete("/collections/#{id}/remove", photo_id: photo.id)
      response.status == 204
    end

  end
end
