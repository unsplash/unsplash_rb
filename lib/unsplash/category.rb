module Unsplash
  class Category < Model

    class << self
      def all
        JSON.parse(connection.get("/categories/").body).map do |category|
          new category.to_hash
        end
      end

      def find(id)
        new connection.get("/categories/#{id}").to_hash
      end
    end

    def photos(page = 1, per_page = 10)
      qs = "page=#{page}&per_page=#{per_page}"
      list = JSON.parse(connection.get("/categories/#{id}/photos?#{qs}").body)
      list.map do |photo|
        Unsplash::Photo.new photo.to_hash
      end
    end
  end
end