require 'oauth'
require 'json'
require 'csv'

class GoodDataTwitterAds::LineItems
	attr_reader :client

	def initialize config={}
		@client = config[:client]
	end

#-----------------------------------------------------LIST OF CAMPAIGNS------------------------------------------------------------------
	# This function will fetch list of all campaign based on account id
	# INPUT PARAMETER ---> account_id,  json -->true or false
	# IF :json => true is given as an input pararmeter , then the raw JSON files are stored locally as "daily_campaigns_#{account_id}_#{date}_#{counter}">
	# Change the file name as required
	# CURRENT DATE IS AUTOMATICALLY APPENDED  with all raw json files since this is a snapshot
	def list_lineitems(config={})

		account_id = config[:account_id]

		if account_id.nil? || account_id==''
			raise ArgumentError, "account_id is required to get the account detail. Please use list_of_accounts endpoint to get a list of account ids"
		end

		json = true if config[:json]==true
		csv  = true unless config[:csv]==false

		lineitems  = Hash.new
		file_names = Array.new
		response_array = Array.new

		cursor = '1' # Pagination variable
		counter = 1

		while(cursor!=nil) do
			if (counter==1)
				response = @client.fresh_token.request(:get, "https://ads-api.twitter.com/0/accounts/#{account_id}/line_items")
			else
				response = @client.fresh_token.request(:get, "https://ads-api.twitter.com/0/accounts/#{account_id}/line_items?cursor=#{cursor}&count=1000")
			end

			#Create this array of responses which can be sent to produce respective csv file
			response_array.push(response.body)

			date = Time.now.to_date.to_s
			file_name = "daily_lineitems_#{account_id}_#{date}_#{counter}.json"
			File.open(file_name, "w") { |f|
				f.write(response.body)
				file_names.push(file_name)
			} if(json==true)

			#Parse the JSON response partially to display ID & Name for initial pass
			request =  JSON.parse(response.body)
			request['data'].each { |f|
				lineitems['id'] = f['id']
				}unless request['data'].nil?

			cursor =  request['next_cursor']

			counter = counter +1
		end

		puts lineitems
		#Write to CSV file by default unless someone disabled it
		list_lineitems_csv(response_array) if csv!=false
		return lineitems
	end
#-----------------------------------------------------LINEITEM DETAILS------------------------------------------------------------------
	# This function will fetch details of a lineitem based on  account id
	# INPUT PARAMETER ---> account_id, line_item_id, json -->true or false
	# IF :json => true is given as an input pararmeter , then the raw JSON files are stored locally as "daily_lineitemdetail_#{account_id}_#{line_item_id}_#{date}">
	# Change the file name as required
	# CURRENT DATE IS AUTOMATICALLY APPENDED  with all raw json files since this is a snapshot
	def lineitem_detail(config={})

		account_id = config[:account_id]
		lineitems  = conflig[:lineitem_id]

		if lineitems.nil? || lineitems.empty? || lineitems=='' || account_id.nil? || account_id==''
			raise ArgumentError, "lineitem id  & account id is required to get the lineitem detail. Please use list_lineitems endpoint to get a list of list_of_campaigns ids" 
		end

		json = true if config[:json]==true
		csv  = true unless config[:csv]==false

		file_names = Array.new
		response_array = Array.new

		lineitems.each {|line_item_id|
			response = @client.fresh_token.request(:get, "https://ads-api.twitter.com/0/accounts/#{account_id}/line_items/#{line_item_id}")
			request = JSON.parse(response.body)

			#Create this array of responses which can be sent to produce respective csv file
			response_array.push(response.body)

			date = Time.now.to_date.to_s
			file_name = "daily_lineitemdetail_#{account_id}_#{line_item_id}_#{date}.json"
			File.open(file_name, "w") { |f|
				f.write(response.body)
				file_names.push(file_name)
			} if(json==true)
		} unless lineitems.nil?
		lineitem_detail_csv(response_array) if csv!=false
	end

#---------------------------------------------------LIST OF CAMPAIGNS CSV------------------------------------------------------------
	# This will create csv file for list_of_campaign and dump it in the local directory
	# INPUT PARAMETER ---> ARRAY OF RESPONSES when the API calls are made. They are stored in response_array 
	# Mostly all fields are used but if required ADD OR DELETE FIELDS
	# OUTPUT FILE NAME = 'campaign_list.csv' . The file is "" quoted
	def list_lineitems_csv(file_names)

		CSV.open('lineitems_list.csv','wb',:force_quotes => true) do |csv|
			csv << ['id','campaign_id','account_id','created_at','bid_amount_local_micro','currency','deleted','include_sentiment','paused','placement_type','suggested_high_cpe_bid_local_micro','suggested_low_cpe_bid_local_micro','updated_at','objective']
			file_names.each{ |file|
				
				data_hash = JSON.parse(file)
				data_hash['data'].each do |item|
					id             						=  item['id']
					campaign_id                			=  item['campaign_id']
					account_id              			=  item['account_id']
					created_at 							=  item['created_at']
					bid_amount_local_micro          	=  item['bid_amount_local_micro']
					currency           					=  item['currency']
					deleted           					=  item['deleted']
					include_sentiment					=  item['include_sentiment']
					paused   							=  item['paused']
					placement_type 						=  item['placement_type']
					suggested_high_cpe_bid_local_micro  =  item['suggested_high_cpe_bid_local_micro']
					suggested_low_cpe_bid_local_micro	=  item['suggested_low_cpe_bid_local_micro']
					updated_at							=  item['updated_at']
					objective							=  item['objective']
					csv << [id,campaign_id,account_id,created_at,bid_amount_local_micro,currency,deleted,include_sentiment,paused,placement_type,suggested_high_cpe_bid_local_micro,suggested_low_cpe_bid_local_micro,updated_at,objective]
				end
			}unless file_names.nil?
		end
	end

#--------------------------------------------LINEITEM DETAILS CSV---------------------------------------------------------------------
	# This will create csv file for campaign_detail and dump it in the local directory
	# INPUT PARAMETER ---> ARRAY OF RESPONSES when the API calls are made. They are stored in response_array 
	# Mostly all fields are used but if required ADD OR DELETE FIELDS
	# OUTPUT FILE NAME = 'lineitem_detail.csv' . The file is "" quoted
	def lineitem_detail_csv(file_names)
		CSV.open('lineitem_detail.csv','wb',:force_quotes => true) do |csv|
			csv << ['id','campaign_id','account_id','created_at','bid_amount_local_micro','currency','deleted','include_sentiment','paused','placement_type','suggested_high_cpe_bid_local_micro','suggested_low_cpe_bid_local_micro','updated_at','objective']
			file_names.each{ |file|
				
				data_hash = JSON.parse(file)
				item = data_hash['data']
				id             						=  item['id']
				campaign_id                			=  item['campaign_id']
				account_id              			=  item['account_id']
				created_at 							=  item['created_at']
				bid_amount_local_micro          	=  item['bid_amount_local_micro']
				currency           					=  item['currency']
				deleted           					=  item['deleted']
				include_sentiment					=  item['include_sentiment']
				paused   							=  item['paused']
				placement_type 						=  item['placement_type']
				suggested_high_cpe_bid_local_micro  =  item['suggested_high_cpe_bid_local_micro']
				suggested_low_cpe_bid_local_micro	=  item['suggested_low_cpe_bid_local_micro']
				updated_at							=  item['updated_at']
				objective							=  item['objective']
				csv << [id,campaign_id,account_id,created_at,bid_amount_local_micro,currency,deleted,include_sentiment,paused,placement_type,suggested_high_cpe_bid_local_micro,suggested_low_cpe_bid_local_micro,updated_at,objective]
			}unless file_names.nil?
		end
	end
end
