module Unsplash
  class User < Model

    class << self

      def find(username)
        new JSON.parse(connection.get("/users/#{username}").body)
      end

      def current
        new JSON.parse(connection.get("/me").body)
      end
    end

    def photos
      list = JSON.parse(connection.get("/users/#{username}/photos").body)
      list.map do |photo|
        Unsplash::Photo.new photo.to_hash
      end
    end

    def update(params)
      # TODO
    end


  end

end