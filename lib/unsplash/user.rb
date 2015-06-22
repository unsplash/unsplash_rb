module Unsplash
  class User < OpenStruct
    include Model

    class << self

      def find(username)
        new connection.get("/users/#{username}").to_hash
      end

      def current
        # TODO
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