require 'oauth'
require 'json'
require 'csv'

class GoodDataTwitterAds::Accounts

	attr_reader :client

	def initialize(config={})
		@client = config[:client]
	end

	#-----------------------------------------------------LIST OF ACCOUNTS------------------------------------------------------------------
	# This function will fetch list of all Twitter Ad accounts for the authenticating user
	# INPUT PARAMETER ---> json(optional) -->true or false----> default to false
	# IF :json => true is given as an input pararmeter , then the raw JSON files are stored locally as "daily_accounts_#{date}_#{counter}.json
	# Change the file name as required
	# CURRENT DATE IS AUTOMATICALLY APPENDED  with all raw json files since this is a snapshot
	def list_accounts config={}

		json = true if config[:json]==true
		csv  = true unless config[:csv]==false

		accounts       = Hash.new
		file_names     = Array.new
		response_array = Array.new

		cursor = '1'
		counter = 1

		while(cursor!=nil) do
			if (counter==1)
				response = @client.fresh_token.request(:get, "https://ads-api.twitter.com/0/accounts")
			else
				response = @client.fresh_token.request(:get, "https://ads-api.twitter.com/0/accounts?cursor=#{cursor}&count=1000")
			end
			#Create this array of responses which can be sent to produce respective csv file
			response_array.push(response.body)

			date = Time.now.to_date.to_s

			file_name = "daily_accounts_#{date}_#{counter}.json"

			File.open(file_name, "w") { |f|
				f.write(response.body)
				file_names.push(file_name)
			} if(json==true)

			request =  JSON.parse(response.body)
			request['data'].each { |f|
				accounts[f['name']] = f['id']
				}unless request['data'].nil?
			cursor =  request['next_cursor']
			counter = counter +1
		end
		list_accounts_csv(response_array) if csv!=false
		puts accounts # PRINT TO CONSOLE
		return accounts
	end

#-----------------------------------------------------ACCOUNT DETAILS------------------------------------------------------------------
	# This function will fetch details of a Twitter Ad Account based on  account id
	# INPUT PARAMETER ---> account_id , json(optional) -->true or false--> default to false
	# IF :json => true is given as an input pararmeter , then the raw JSON files are stored locally as "daily_accountdetail_#{account_id}_#{date}.json">
	# Change the file name as required
	# CURRENT DATE IS AUTOMATICALLY APPENDED  with all raw json files since this is a snapshot
	def account_detail(config={})
		accounts = config[:account_id]

		if accounts.nil? || accounts=='' || accounts.empty?
			raise ArgumentError, "account_id is required to get the account detail. Please use list_of_accounts endpoint to get a list of account ids" 
		end

		json = true if config[:json]==true
		csv  = true unless config[:csv]==false

		file_names     = Array.new
		#Create this array of responses which can be sent to produce respective csv file
		response_array = Array.new

		accounts.each {|account_id|
			response = @client.fresh_token.request(:get, "https://ads-api.twitter.com/0/accounts/#{account_id}")
			response_array.push(response.body)

			date = Time.now.to_date.to_s
			file_name = "daily_accountdetail_#{account_id}_#{date}.json"
			File.open(file_name, "w") { |f|
				f.write(response.body)
				file_names.push(file_name)
				puts "#{file_name} created"
			} if(json==true)
		} unless accounts.nil?
		#puts response_array
		accounts_detail_csv(response_array) if csv!=false
	end


#---------------------------------------------------LIST OF ACCOUNTS CSV------------------------------------------------------------
	# This will create csv file for list_of_accounts and dump it in the local directory
	# INPUT PARAMETER ---> ARRAY OF RESPONSES when the API calls are made. They are stored in response_array 
	# Mostly all fields are used but if required ADD OR DELETE FIELDS
	# OUTPUT FILE NAME = 'campaign_list.csv' . The file is "" quoted
	def list_accounts_csv(file_names)

		CSV.open('account_list.csv','wb',:force_quotes => true) do |csv|
			csv << ['id','name','updated_at','timezone_switch_at','salt','created_at','deleted','timezone','approval_status']
			file_names.each{ |file|

				data_hash = JSON.parse(file)
				data_hash['data'].each do |item|
					id             		 =  item['id']
					name              	 =  item['name']
					updated_at           =  item['updated_at']
					timezone_switch_at   =  item['timezone_switch_at']
					salt 				 =  item['salt']
					created_at           =  item['created_at']
					deleted              =  item['deleted']
					timezone           	 =  item['timezone']
					approval_status   	 =  item['approval_status']
					csv << [id,name,updated_at,timezone_switch_at,salt,created_at,deleted,timezone,approval_status]
				end
			}unless file_names.nil?
		end
	end

#--------------------------------------------ACCOUNT DETAILS CSV---------------------------------------------------------------------
	# This will create csv file for list_of_accounts and dump it in the local directory
	# INPUT PARAMETER ---> ARRAY OF RESPONSES when the API calls are made. They are stored in response_array 
	# Mostly all fields are used but if required ADD OR DELETE FIELDS
	# OUTPUT FILE NAME = 'account_detail.csv' . The file is "" quoted
	def accounts_detail_csv(file_names)
		CSV.open('account_detail.csv','wb',:force_quotes => true) do |csv|
			csv << ['id','name','updated_at','timezone_switch_at','salt','created_at','deleted','timezone','approval_status']
			file_names.each{ |file|
				data_hash = JSON.parse(file)
				item = data_hash['data']
				id             		 =  item['id']
				name              	 =  item['name']
				updated_at           =  item['updated_at']
				timezone_switch_at   =  item['timezone_switch_at']
				salt 				 =  item['salt']
				created_at           =  item['created_at']
				deleted              =  item['deleted']
				timezone           	 =  item['timezone']
				approval_status   	 =  item['approval_status']
				csv << [id,name,updated_at,timezone_switch_at,salt,created_at,deleted,timezone,approval_status]

			}unless file_names.nil?
		end
	end
end
