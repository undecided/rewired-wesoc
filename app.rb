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
        requires :texts, type: Array, desc: "Some texts to give the sentiment for"
      end
      post do
        texts = Utils.analyse params[:texts]
        {
          :overall_feeling => Utils.summarize(texts),
          :texts => texts
        }
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
          tweets = Utils.analyse tweets.map(&:text)

          {
            :twitter => {
              :overall_feeling => Utils.summarize(tweets),
              :tweets => tweets
            }
          }
        end
      end
    end
  end
end


