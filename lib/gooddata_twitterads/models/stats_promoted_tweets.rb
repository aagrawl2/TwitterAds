require 'oauth'
require 'json'
require 'csv'
require 'time'
require 'fileutils'

class GoodDataTwitterAds::StatsPromotedTweets
	attr_reader :client

	def initialize config={}
		@client = config[:client]
	end

#-----------------------------------------------------PROMOTED TWEETS STATS------------------------------------------------------------------
	# This function will get a list of promoted tweets stats based on account id and id(obtained from list_promoted_tweets endpoint)
	# INPUT PARAMETER ---> 
	# 			:account_id =>'',
	# 			:id  =>'',
	# 			:json(optional) => true or false--->(default)
	# If :json => true is given as an input pararmeter , then the raw JSON files are stored locally as "daily_statspromotedtweets_#{account_id}_#{id}_#{start_date}_#{end_date}.json"
	def stats_promoted_tweets(config={})

		account_id = config[:account_id]
		ids  = config[:id]
		start_date = config[:start_date]
		end_date   = config[:end_date]

		if ids.nil? || ids.empty? || ids=='' || account_id.nil? || account_id==''
			raise ArgumentError, "ids  & account id is required to get the stats promoted tweets. Please use list_promoted_tweets endpoint to get a list of ids" 
		end

		if start_date.nil? || start_date.empty? || start_date=='' || end_date.nil? || end_date==''
			raise ArgumentError, "start date & end date is required . We are missing parameters"
		end

		json = true if config[:json]==true
		csv  = true unless config[:csv]==false

		file_names = Array.new
		response_array = Array.new

		ids.each { |id|
			response = @client.fresh_token.request(:get, "https://ads-api.twitter.com/0/stats/accounts/#{account_id}/promoted_tweets/#{id}?granularity=DAY&start_time=#{start_date}&end_time=#{end_date}")

			#Create this array of responses which can be sent to produce respective csv file
			response_array.push(response.body)

			file_name = "daily_statspromotedtweets_#{account_id}_#{id}_#{start_date}_#{end_date}.json"

			File.open(file_name, "w") { |f|
				f.write(response.body)
				file_names.push(file_name)
			} if(json==true)
		} unless ids.nil?
		stats_promoted_tweets_csv(response_array) if csv!=false
	end


	#--------------------------------------------STATS PROMOTED TWEETS CSV---------------------------------------------------------------------
	# This will create csv file for stats_promoted_Tweets and dump it in the local directory
	# INPUT PARAMETER ---> ARRAY OF RESPONSES when the API calls are made. They are stored in response_array 
	# Mostly all fields are used but if required ADD OR DELETE FIELDS
	# OUTPUT FILE NAME = 'stats_pm.csv' . The file is "" quoted
	def stats_promoted_tweets_csv(file_names)
		CSV.open('stats_pm.csv','wb',:force_quotes => true) do |csv|
			csv << ['id','account_id','fact_name','fact_subnm','fact_value','activity_date']
			file_names.each{ |file|
				data_hash  = JSON.parse(file)

				id         = data_hash['request']['params']['promoted_tweet_id']
				account_id = data_hash['request']['params']['account_id']

				start_date = Time.parse(data_hash['request']['params']['start_time']).to_date.to_s
				end_date   = Time.parse(data_hash['request']['params']['end_time']).to_date.to_s

				# This is used for calcualting difference betweens start & end date
				diff_dates = ((Time.parse(end_date).to_date) - (Time.parse(start_date).to_date)).to_i

				#Store all the dates in an array so that we can populate them in the csv file against each correct records
				dates = Array.new
				temp = Time.parse(start_date).to_date
				for i in 0..diff_dates
					dates.push(temp.to_s)
					temp = temp +1
				end

				counter = 0 # This counter is used for resetting the dates whenever new fact is acuqired

				keys = data_hash['data'].keys # Generate all keys so that we dont have to specify fact names explicitly
				keys.each do |item|
					if data_hash['data'][item].is_a? Array
						data_hash['data'][item].each { |nested|
							csv << [id, account_id, item, nil, nested, dates[counter]]
							counter = counter + 1
							counter = 0 if(counter>=(diff_dates)) # Resetting the counter
						} unless data_hash['data'][item].nil?

					elsif data_hash['data'][item].is_a? String

					elsif data_hash['data'][item].is_a? Hash
						nested_keys = data_hash['data'][item].keys
						nested_keys.each { |f|
							data_hash['data'][item][f].each do |t|
								csv << [id, account_id, item, f, t, dates[counter]]
								counter = counter + 1
								counter = 0 if(counter>=(diff_dates)) # Resetting the counter
							end
						} unless nested_keys.nil?
					end
				end
			}unless file_names.nil?
		end
	end
end
