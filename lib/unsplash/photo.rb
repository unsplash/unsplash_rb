module Unsplash
  class Photo < Model

    class << self

      def find(public_id)
        new JSON.parse(connection.get("/photos/#{public_id}").body)
      end

      def search(query, page = 1, per_page = 10)
        params = {
          query:    query,
          page:     page,
          per_page: per_page
        }
        parse_list connection.get("/photos/search/", params).body
      end

      def all(page = 1, per_page = 10)
        params = {
          page:     page,
          per_page: per_page
        }
        parse_list connection.get("/photos/", params).body
      end

      def create(filepath)
        file = Faraday::UploadIO.new(filepath, "image/jpeg")
        new JSON.parse(connection.post("/photos", photo: file).body)
      end

      private

      def parse_list(json)
        JSON.parse(json).map { |photo| new photo }
      end

    end
  end
end