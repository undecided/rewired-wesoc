WESOC_ENV = ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'

Bundler.require(:default, WESOC_ENV.to_sym)
Dotenv.load

require 'logger'
LOGGER = Logger.new("log/#{WESOC_ENV}.log") rescue Logger.new($STDERR)
LOGGER.warn "App restarted"

require './utils'

module WeSoc
  class API < Grape::API
    include Config

    logger LOGGER
    format :json
    rescue_from :all
    version 'v1', using: :header, vendor: 'rewired_state'

    get "/" do
      redirect 'index.html'
    end

    resource :sentiment do
      desc "Return social responses to a company"
      params do
        requires :text, type: String, desc: "Some text to give the sentiment for"
      end
      route_param :text do
        get do

        end
      end
    end

    resource :companies do
      desc "Return social responses to a company"
      params do
        requires :name, type: String, desc: "Company name"
      end

      route_param :name do
        get do
          tweets = Utils.twitter.search(params[:name], :lang => :en)
          tweets = tweets.map do |t|
            {:text => t.text, :sentiment => Utils.sentiment_score(t.text) }
          end

          sorted = tweets.sort_by_key :sentiment

          {
            :twitter => {
              :overall_feeling => {
                :min => sorted.middle_item ? sorted.first[:sentiment] : 0,
                :max => sorted.middle_item ? sorted.last[:sentiment] : 0,
                :mean => sorted.mean_by_key(:sentiment),
                :median => sorted.middle_item ? sorted.middle_item[:sentiment] : 0
              },
              :tweets => sorted
            }
          }
        end
      end
    end
  end
end


