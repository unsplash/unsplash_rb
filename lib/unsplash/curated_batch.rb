module Unsplash
  class CuratedBatch < OpenStruct
    include Model

    class << self
      def find(id)
        new connection.get("/curated_batches/#{id}").to_hash
      end

      def all(page = 1, per_page = 10)
        qs = "page=#{page}&per_page=#{per_page}"
        list = JSON.parse(connection.get("/curated_batches/?#{qs}").body)
        list.map do |cb|
          new cb.to_hash
        end
      end
    end

    def photos
      list = JSON.parse(connection.get("/curated_batches/#{id}/photos").body)
      list.map do |photo|
        Unsplash::Photo.new photo.to_hash
      end
    end
  end
end