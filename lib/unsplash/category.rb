module Unsplash
  class Category < Model

    class << self
      def all
        JSON.parse(connection.get("/categories/").body).map do |category|
          new category
        end
      end

      def find(id)
        new JSON.parse(connection.get("/categories/#{id}").body)
      end
    end

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