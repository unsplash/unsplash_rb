module Unsplash
  module Model

    def self.included(base)
      base.extend(ClassMethods)
    end

    def connection
      self.class.connection
    end

    module ClassMethods
      def connection
        @@connection ||= Connection.new(Unsplash.configuration.application_id,
                                        Unsplash.configuration.application_secret)
      end

      def connection=(conn)
        @@connection = conn
      end

    end
  end
end