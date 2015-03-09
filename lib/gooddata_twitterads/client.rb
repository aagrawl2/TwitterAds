require 'oauth'
require 'json'

require_relative 'models/accounts'
require_relative 'models/campaigns'
require_relative 'models/lineitems'
require_relative 'models/promoted_tweets'
require_relative 'models/stats_promoted_tweets'




class GoodDataTwitterAds::Client

	attr_reader :fresh_token
	def initialize config={}
		consumer_key        = config.delete(:consumer_key)
		consumer_secret     = config.delete(:consumer_secret)
		access_token        = config.delete(:access_token)
		access_token_secret = config.delete(:access_token_secret)
		@fresh_token        = create_token(consumer_key,consumer_secret,access_token,access_token_secret)
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


