module Unsplash # nodoc:

  # Unsplash User operations.
  class User < Client

    class << self

      # Get a user.
      # @param username [String] the username of the user to retrieve.
      # @return [Unsplash::User] the Unsplash User.
      def find(username)
        new JSON.parse(connection.get("/users/#{username}").body)
      end

      # Get the currently-logged in user.
      # @return [Unsplash::User] the current user.
      def current
        new JSON.parse(connection.get("/me").body)
      end

      # Update the current user.
      # @param params [Hash] the hash of attributes to update.
      # @return [Unsplash::User] the updated user.
      def update_current(params)
        Unsplash::User.new JSON.parse(connection.put("/me", params).body)
      end

    end

    # Get a list of photos uploaded by the user.
    # @return [Array] a list of +Unsplash::Photo+ objects. 
    def photos
      list = JSON.parse(connection.get("/users/#{username}/photos").body)
      list.map do |photo|
        Unsplash::Photo.new photo.to_hash
      end
    end

  end

end