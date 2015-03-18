require 'oauth'
require 'json'

require_relative 'models/accounts'
require_relative 'models/campaigns'
require_relative 'models/lineitems'
require_relative 'models/promoted_tweets'
require_relative 'models/stats_promoted_tweets'




class GoodDataTwitterAds::Client

	def initialize config={}
		consumer_key        = config.delete(:consumer_key)
		consumer_secret     = config.delete(:consumer_secret)
		access_token        = config.delete(:access_token)
		access_token_secret = config.delete(:access_token_secret)
		@fresh_token        = create_token(consumer_key,consumer_secret,access_token,access_token_secret)
		@counter            = 0 # This is used to see if we are making 1800 API calls per 15 min window
		@Timer              = Time.now
	end

	def accounts
		GoodDataTwitterAds::Accounts.new :client =>self
	end

	def campaigns()
		GoodDataTwitterAds::Campaigns.new :client =>self
	end

	def lineitems()
		GoodDataTwitterAds::LineItems.new :client =>self
	end

	def promoted_tweets()
		GoodDataTwitterAds::PromotedTweets.new :client =>self
	end

	def stats()
		GoodDataTwitterAds::StatsPromotedTweets.new :client =>self
	end


	def fresh_token()
		current_time = Time.now
		if @counter >1800 and (current_time - @Timer)<800 # 800 refers to seconds i.e. 13 mintutes 
			puts "We have exceeded 1800 API calls per 15 minute window. Sleeping"
			sleep_time  = 900 - (current_time - @Timer)
			sleep(sleep_time) # This is calculated so that we sleep for 15 minutes - (time we have spent uptil now)
			puts "Resetting counters and timer"
			@counter = 0 # Resetting counter
			@Timer = Time.now # Resetting Time
		end
		@counter = @counter +1
		puts "API call = #{@counter}"
		return @fresh_token
	end

	private
	def create_token(consumer_key,consumer_secret,access_token,access_token_secret)
		if consumer_key.nil? || consumer_secret.nil? || access_token.nil? || access_token_secret.nil?
        	raise ArgumentError, ":user_id and :consumer_secret and :access_token and :access_token_secret required"
      	end
		consumer = OAuth::Consumer.new(consumer_key, consumer_secret, { :site => "https://api.twitter.com", :scheme => :header })
		token_hash = { :oauth_token => access_token, :oauth_token_secret => access_token_secret }
		fresh_token = OAuth::AccessToken.from_hash(consumer, token_hash)
		return fresh_token
	end


end
