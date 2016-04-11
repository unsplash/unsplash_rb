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
      def create(title:, description: "", private: false)
        params = { 
          title:       title,
          description: description,
          private:     private
        }
        Unsplash::Collection.new JSON.parse(connection.post("/collections", params).body)
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

    # Get a list of the photos contained in this collection.
    # @return [Array] The list of +Unsplash::Photo+s in the collection.
    def photos
      list = JSON.parse(connection.get("/collections/#{id}/photos").body)
      list.map { |photo| Unsplash::Photo.new photo }
    end

  end
end