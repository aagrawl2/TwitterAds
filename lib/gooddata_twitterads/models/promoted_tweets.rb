require 'oauth'
require 'json'
require 'csv'

class GoodDataTwitterAds::PromotedTweets
	attr_reader :client

	def initialize config={}
		@client = config[:client]
	end

#-----------------------------------------------------LIST OF PROMOTED TWEETS------------------------------------------------------------------
	# This function will get a list of promoted tweets based on account id 
	# INPUT PARAMETER ---> account_id,  json(optional) -->true or false--->(default)
	# Outputs list of promoted  tweets with their ids in form of Hash
	# If :json => true is given as an input pararmeter , then the raw JSON files are stored locally as "daily_promoted_tweets_#{account_id}_#{date}_#{counter}.json"
	def list_promoted_tweets(config={})

		account_id = config[:account_id] #Extract account id from input parameters

		if account_id.nil? || account_id==''
			raise ArgumentError, "account_id is required to get the promoted tweets. Please use list_of_accounts endpoint to get a list of account ids"
		end

		#CHECK IF WE WANT JSON & CSV FILES AS OUTPUT
		json = true if config[:json]==true
		csv  = true unless config[:csv]==false

		#OUTPUT OBJECTS
		promoted_tweets = Hash.new
		file_names      = Array.new
		response_array  = Array.new

		cursor = '1' # Pagination variable
		counter = 1

		while(cursor!=nil) do
			if (counter==1)
				response = @client.fresh_token.request(:get, "https://ads-api.twitter.com/0/accounts/#{account_id}/promoted_tweets")
			else
				response = @client.fresh_token.request(:get, "https://ads-api.twitter.com/0/accounts/#{account_id}/promoted_tweets?cursor=#{cursor}&count=1000")
			end

			#Create this array of responses which can be sent to produce respective csv file
			response_array.push(response.body)

			date = Time.now.to_date.to_s
			file_name = "daily_promoted_tweets_#{account_id}_#{date}_#{counter}.json"

			File.open("daily_promoted_tweets_#{account_id}_#{date}_#{counter}.json", "w") { |f|
				f.write(response.body)
				file_names.push(file_name)
			} if(json==true)

			request =  JSON.parse(response.body)
			request['data'].each { |f|
				promoted_tweets[f['name']] = f['id']
				}unless request['data'].nil?

			cursor =  request['next_cursor']

			counter = counter +1
		end
		list_promoted_tweets_csv(account_id,response_array) if csv!=false
		return promoted_tweets
	end


	#---------------------------------------------------LIST OF PROMOTED TWEETS CSV------------------------------------------------------------
	# This will create csv file for list_of_campaign and dump it in the local directory
	# INPUT PARAMETER ---> ARRAY OF RESPONSES when the API calls are made. They are stored in response_array 
	# Mostly all fields are used but if required ADD OR DELETE FIELDS
	# OUTPUT FILE NAME = 'campaign_list.csv' . The file is "" quoted
	def list_promoted_tweets_csv(account_id,file_names)

		CSV.open('promoted_tweets_list.csv','wb',:force_quotes => true) do |csv|
			csv << ['id','tweet_id','line_item_id','account_id','created_at','approval_status','deleted','paused','updated_at']
			file_names.each{ |file|
				data_hash = JSON.parse(file)
				data_hash['data'].each do |item|
					id             					=  item['id']
					tweet_id                		=  item['tweet_id']
					line_item_id              		=  item['line_item_id']
					servable    					=  item['servable']
					created_at 						=  item['created_at']
					approval_status                 =  item['approval_status']
					deleted          			    =  item['deleted']
					paused           				=  item['paused']
					updated_at						=  item['updated_at']
					csv << [id,tweet_id,line_item_id,account_id,created_at,approval_status,deleted,paused,updated_at]
				end
			}unless file_names.nil?
		end
	end


end
