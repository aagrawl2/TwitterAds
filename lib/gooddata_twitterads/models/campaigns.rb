require 'oauth'
require 'json'
require 'csv'

class GoodDataTwitterAds::Campaigns
	attr_reader :client

	def initialize config={}
		@client = config[:client]
	end

#-----------------------------------------------------LIST OF CAMPAIGNS------------------------------------------------------------------
	# This function will fetch list of all campaign based on account id
	# INPUT PARAMETER ---> account_id,  json -->true or false. Eg 
	# IF :json => true is given as an input pararmeter , then the raw JSON files are stored locally as "daily_campaigns_#{account_id}_#{date}_#{counter}">
	# Change the file name as required
	# CURRENT DATE IS AUTOMATICALLY APPENDED  with all raw json files since this is a snapshot
	def list_campaigns(config={})

		account_id = config[:account_id]

		if account_id.nil? || account_id==''
			raise ArgumentError, "account_id is required to get the account detail. Please use list_of_accounts endpoint to get a list of account ids"
		end

		raise ArgumentError, "csv parameter should be either true,false or do not pass it since by default it takes true" if config[:csv]!=true && config[:csv]!=false && config[:csv]!=nil
		raise ArgumentError, "csv parameter should be either true,false or do not pass it since by default it takes true" if config[:csv]!=true && config[:csv]!=false && config[:csv]!=nil
		json = true if config[:json]==true
		csv  = true if config[:csv]==true || config[:csv].nil?

		campaigns  = Hash.new
		file_names = Array.new
		response_array = Array.new

		cursor = '1' # Pagination variable
		counter = 1
		while(cursor!=nil) do
			if (counter==1)
				response = @client.fresh_token.request(:get, "https://ads-api.twitter.com/0/accounts/#{account_id}/campaigns")
			else
				response = @client.fresh_token.request(:get, "https://ads-api.twitter.com/0/accounts/#{account_id}/campaigns?cursor=#{cursor}&count=1000")
			end

			#Create this array of responses which can be sent to produce respective csv file
			response_array.push(response.body)

			date = Time.now.to_date.to_s
			file_name = "daily_campaigns_#{account_id}_#{date}_#{counter}.json"
			File.open(file_name, "w") { |f|
				f.write(response.body)
				file_names.push(file_name)
			} if(json==true)

			#Parse the JSON response partially to display ID & Name for initial pass
			request =  JSON.parse(response.body)
			request['data'].each { |f|
				campaigns[f['name']] = f['id']
				}unless request['data'].nil?

			cursor =  request['next_cursor']

			counter = counter +1
		end

		puts campaigns
		#Write to CSV file by default unless someone disabled it
		list_campaign_csv(response_array) if csv!=false
		return campaigns
	end
#-----------------------------------------------------CAMPAIGN DETAILS------------------------------------------------------------------
	# This function will fetch details of a campaign based on campaign id & account id
	# INPUT PARAMETER ---> account_id, campaign_id, json -->true or false
	# IF :json => true is given as an input pararmeter , then the raw JSON files are stored locally as "daily_accountdetail_account_id_<today's date">
	# Change the file name as required
	# CURRENT DATE IS AUTOMATICALLY APPENDED  with all raw json files since this is a snapshot
	def campaign_detail(config={})

		campaigns  = config[:campaign_id]
		account_id = config[:account_id]

		if campaigns.nil? || campaigns.empty? || campaigns=='' || account_id.nil? || account_id==''
			raise ArgumentError, "campaign_id & account id is required to get the campaign detail. Please use list_of_campaigns endpoint to get a list of list_of_campaigns ids" 
		end

		json = true if config[:json]==true
		csv  = true unless config[:csv]==false

		file_names = Array.new
		response_array = Array.new

		campaigns.each {|campaign_id|
			response = @client.fresh_token.request(:get, "https://ads-api.twitter.com/0/accounts/#{account_id}/campaigns/#{campaign_id}")
			
			#Create this array of responses which can be sent to produce respective csv file
			response_array.push(response.body)

			request = JSON.parse(response.body)
			date = Time.now.to_date.to_s
			file_name = "daily_campaigndetail_#{account_id}_#{campaign_id}_#{date}.json"
			File.open(file_name, "w") { |f|
				f.write(response.body)
				file_names.push(file_name)
			} if(json==true)
		} unless campaigns.nil?
		campaign_detail_csv(response_array) if csv!=false
	end

#---------------------------------------------------LIST OF CAMPAIGNS CSV------------------------------------------------------------
	# This will create csv file for list_of_campaign and dump it in the local directory
	# INPUT PARAMETER ---> ARRAY OF RESPONSES when the API calls are made. They are stored in response_array 
	# Mostly all fields are used but if required ADD OR DELETE FIELDS
	# OUTPUT FILE NAME = 'campaign_list.csv' . The file is "" quoted
	def list_campaign_csv(file_names)

		CSV.open('campaign_list.csv','wb',:force_quotes => true) do |csv|
			csv << ['id','name','start_time','servable','daily_budget_amount_local_micro','end_time','funding_instrument_id','standard_delivery','total_budget_amount_local_micro','paused','account_id','currency','created_at','updated_at','deleted']
			file_names.each{ |file|
				data_hash = JSON.parse(file)
				data_hash['data'].each do |item|
					id             					=  item['id']
					name                			=  item['name']
					start_time              		=  item['start_time']
					servable    					=  item['servable']
					daily_budget_amount_local_micro =  item['daily_budget_amount_local_micro']
					end_time                   		=  item['end_time']
					funding_instrument_id           =  item['funding_instrument_id']
					standard_delivery           	=  item['standard_delivery']
					total_budget_amount_local_micro	=  item['total_budget_amount_local_micro']
					paused   						=  item['paused']
					account_id 						=  item['account_id']
					currency		   				=  item['currency']
					created_at	   					=  item['created_at']
					updated_at						=  item['updated_at']
					deleted							=  item['deleted']
					csv << [id,name,start_time,servable,daily_budget_amount_local_micro,end_time,funding_instrument_id,standard_delivery,total_budget_amount_local_micro,paused,account_id,currency,created_at,updated_at,deleted]
				end
			}unless file_names.nil?
		end
	end

#--------------------------------------------CAMPAIGN DETAILS CSV---------------------------------------------------------------------
	# This will create csv file for campaign_detail and dump it in the local directory
	# INPUT PARAMETER ---> ARRAY OF RESPONSES when the API calls are made. They are stored in response_array 
	# Mostly all fields are used but if required ADD OR DELETE FIELDS
	# OUTPUT FILE NAME = 'campaign_detail.csv' . The file is "" quoted
	
	def campaign_detail_csv(file_names)
		CSV.open('campaign_detail.csv','wb',:force_quotes => true) do |csv|
			csv << ['id','name','start_time','servable','daily_budget_amount_local_micro','end_time','funding_instrument_id','standard_delivery','total_budget_amount_local_micro','paused','account_id','currency','created_at','updated_at','deleted']
			file_names.each{ |file|
				data_hash = JSON.parse(file)
				item = data_hash['data']
				id             					=  item['id']
				name                			=  item['name']
				start_time              		=  item['start_time']
				servable    					=  item['servable']
				daily_budget_amount_local_micro =  item['daily_budget_amount_local_micro']
				end_time                   		=  item['end_time']
				funding_instrument_id           =  item['funding_instrument_id']
				standard_delivery           	=  item['standard_delivery']
				total_budget_amount_local_micro	=  item['total_budget_amount_local_micro']
				paused   						=  item['paused']
				account_id 						=  item['account_id']
				currency		   				=  item['currency']
				created_at	   					=  item['created_at']
				updated_at						=  item['updated_at']
				deleted							=  item['deleted']
				csv << [id,name,start_time,servable,daily_budget_amount_local_micro,end_time,funding_instrument_id,standard_delivery,total_budget_amount_local_micro,paused,account_id,currency,created_at,updated_at,deleted]
	
			}unless file_names.nil?
		end
	end




end
