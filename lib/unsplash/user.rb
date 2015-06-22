module Unsplash
  class User < OpenStruct

    class << self

      def connection
        @@connection ||= Connection.new(Unsplash.configuration.application_id,
                                        Unsplash.configuration.application_secret)
      end

      def connection=(conn)
        @@connection = conn
      end

      def find(username)
        new connection.get("/users/#{username}").to_hash
      end

      def current
        # TODO
      end
    end

    def connection
      self.class.connection
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