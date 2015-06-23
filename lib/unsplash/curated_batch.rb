module Unsplash
  class CuratedBatch < Model

    class << self
      def find(id)
        new JSON.parse(connection.get("/curated_batches/#{id}").body)
      end

      def all(page = 1, per_page = 10)
        params = {
          page:     page,
          per_page: per_page
        }
        list = JSON.parse(connection.get("/curated_batches/", params).body)
        list.map { |cb| new cb }
      end
    end

    def photos
      list = JSON.parse(connection.get("/curated_batches/#{id}/photos").body)
      list.map { |photo| Unsplash::Photo.new photo }
    end
  end
end