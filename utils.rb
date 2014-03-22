module WeSoc
  class Utils
    class << self
      def twitter
        @client ||= Twitter::REST::Client.new do |config|
          config.consumer_key        = ENV['TWITTER_CONSUMER_TOKEN']
          config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
          config.access_token        = ENV['TWITTER_KEY']
          config.access_token_secret = ENV['TWITTER_SECRET']
        end
      end

      def sentiment_score(text)
        (@sentiment_analyzer ||= setup_sentimental).get_score text
      end

      def setup_sentimental
        Sentimental.load_defaults
        Sentimental.threshold = 0.1
        Sentimental.new
      end
    end
  end
end


class Array
  def sort_by_method(meth)
    sort { |a, b| a.send(meth) <=> b.send(meth) }
  end

  def sort_by_key(key)
    sort { |a, b| a[key] <=> b[key] }
  end

  def middle_item
    self[length / 2]
  end

  def mean_by_key(key)
    inject(0) {|acc, item| acc + item[key] } / length.to_f
  end
end