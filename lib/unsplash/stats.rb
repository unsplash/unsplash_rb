module Unsplash # :nodoc:

  # Retrieve Unsplash stats
  class Stats < Client

    class << self
      # Get a list of statistics regardling Unsplash as a whole.
      # @return [Hash] The numbers.
      def total
        connection.get_json('/stats/total')
      end
    end
  end

end
