module Unsplash
  class Photo < OpenStruct
    include Model

    class << self

      def find(public_id)
        new connection.get("/photos/#{public_id}").to_hash
      end

      def search(query, page = 1, per_page = 10)
        qs = "query=#{query}&page=#{page}&per_page=#{per_page}"
        parse_list connection.get("/photos/search/?#{qs}").body
      end

      def all(page = 1, per_page = 10)
        qs = "page=#{page}&per_page=#{per_page}"
        parse_list connection.get("/photos/?#{qs}").body
      end

      def create(params)
        # TODO
      end

      private

      def parse_list(json)
        JSON.parse(json).map do |photo|
          new photo.to_hash
        end
      end

    end
  end
end