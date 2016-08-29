module Bathyscaphe
  module Exceptions
    class Addic7edLimit < StandardError
      def message
        'Limit exceeded'
      end
    end
    class NotFound < StandardError
      def message
        "We beliewe addic7ed don't have subtitles for your episode"
      end
    end
    class RedirectedToSearch < StandardError
      def message
        "Suddenly our bathyscaphe crashed into 'Search results page'"
      end
    end
    class ScrapeFailed < StandardError
      def message
        "We didn't find your subtitles for some reason"
      end
    end
  end
end
