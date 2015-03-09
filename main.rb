require 'json'
require 'bundler/cli'
require 'bundler'
require 'csv'
require 'rubygems'
require 'sequel'
require 'jdbc/dss'
require 'uri'
require 'time'
require 'pp'
require_relative './lib/twitterads'
require_relative './lib/helpers'

#---------------------------------------------3rd Party GEM INSTALLATION------------------------------------------------------------------------
#This is used in case oauth is not installed in your system.
#If you are runnning this locally and have oauth installed , comment out the last three lines in the block
#If not , then this will make sure all the dependencies are installed and then the program is run
#Gemfile is used to input all gems which are required .If you are using other gems , populate this file with required ones.

#bundle = Bundler::CLI.new
#bundle.invoke(:install,[],:path => './',:verbose => false, :deployment => false)
#Bundler.setup(:default, :ci)

require 'oauth'
#--------------------------------------------INPUT PARAMETERS FOR CONNECTION---------------------------------------------------------------------
#INPUT PARAMETERS FOR OAUTH1a
#Please refer to https://developer.gooddata.com/article/oauth1  for setting up these input parameters
consumer_key        = ''
consumer_secret     = ''
access_token        = ''
access_token_secret = ''

#INPUT PARAMETERS FOR S3 
access_key_id = ''
secret_access_key = ''
bucket_name = 'gdc-ms-cust'
path_to_s3_folder='AIDAJNUX6HKJ46IXAJFZU_gdc-ms-cust_temp/source/sitecat/'

#INPUT PARAMETERS FOR ADS(DB)
username 		 = ''
password 		 = ''
ads_instance_url = 'jdbc:dss://na1.secure.gooddata.com/gdc/dss/instances/<INSTANCE_ID>' # Replace with proper instance id


#--------------------------------------------CREATE OAUATH1 OBJECT--------------------------------------------------------------
#This will call create access_token object which is used in all API calls
client = GoodDataTwitterAds.connect(:consumer_key  		 => consumer_key,
								    :consumer_secret 	 => consumer_secret,
								    :access_token    	 => access_token,
								    :access_token_secret => access_token_secret
								    )


#--------------------------------------------CREATE S3 OBJECT--------------------------------------------------------------
client_s3 = Helpers.connect_s3(:access_key_id     => access_key_id,
							   :secret_access_key => secret_access_key,
							   :bucket_name       => bucket_name

#Use this command to upload data to S3
#client_s3.upload(:file_name => '', :path_to_s3_folder => path_to_s3_folder)

#--------------------------------------------CREATE ADS OBJECT--------------------------------------------------------------
client_ads = Helpers.connect_ADS(:username         => username,
							     :password 		   => password,
							     :ads_instance_url => ads_instance_url
							     )

client_ads.write_date('temp','TRUNCATE TABLE src_message_short_long_url')

#---------------------------------------------1. ACCOUNT LIST--------------------------------------------------------------
#Enable the last line in this block to get a list of accounts. input parametes are given in form of Hash object {}
#INPUT PARAMTERS : ( Give input parameters in the following form)
#   :json => boolean (optional)(if true then produce a json response files in local directory)
#Whenever :json=true , this will also produce a json response files in local directory
#Bydefault csv files are produced for each endpoint

#client.accounts.list_accounts(:json =>true).each {|k,v| accounts.push(v)}



#-----------------------------------------------2. ACCOUNT DETAIL------------------------------------------------------------
#Enable the last line in this block to run "Account Details Endpoint". Input parametes are given in form of Hash object {}
#INPUT PARAMTERS : ( Give input parameters in the following form)
#        :account_id=>[] (an array of string required)
#        :json => boolean (optional)(if true then produce a json response files in local directory)
#Bydefault csv files are produced for each endpoint

#client.accounts.account_detail(:account_id => ['1h1e35'], :json =>true)



#----------------------------------------------3. CAMPAIGN LIST------------------------------------------------------------
#Enable the last line in this block to run  "Campaign List Endpoint" for each account. Input parametes are given in form of Hash object {}
#INPUT PARAMTERS :( Give input parameters in the following form)
#        :account_id=>'' (required)
#        :json => boolean (optional)(if true then produce a json response files in local directory)
#Bydefault csv files are produced for each endpoint
#client.campaigns.list_campaigns(:account_id => '1h1e35',:json =>false)



#----------------------------------------------4. AMPAIGN DETAIL------------------------------------------------------------
#Enable the last line in this block to get details for campaigns for each account. input parametes are given in form of Hash object {}
#INPUT PARAMTERS :( Give input parameters in the following form)
#        :account_id  =>'' (required)
#        :campaign_id =>[] (an array of strings required)
#        :json        =>boolean (optional)(if true then produce a json response files in local directory)
#Bydefault csv files are produced for each endpoint

#client.campaigns.campaign_detail(:account_id => '1h1e35',:json =>false,:campaign_id => ['201'])



#----------------------------------------------5. LINE ITEM LIST------------------------------------------------------------
#Enable the last line in this block to get a list of line item for each account. input parametes are given in form of Hash object {}
#INPUT PARAMTERS :
#        :account_id =>'' (required)
#        :json       => boolean (optional)(if true then produce a json response files in local directory)
#Bydefault csv files are produced for each endpoint

#client.lineitems.list_lineitems(:account_id => '1h1e35',:json =>true)



#----------------------------------------------6. LINE ITEM DETAIL------------------------------------------------------------
#Enable the last line in this block to get details for line item for each account. input parametes are given in form of Hash object {}
#INPUT PARAMTERS :
#        :account_id  =>'' (required)
#        :lineitem_id =>[] (an array of strings required)
#        :json        => boolean (optional)(if true then produce a json response files in local directory)
#Bydefault csv files are produced for each endpoint

#client.lineitems.lineitem_detail(:account_id => '1h1e35',:json =>false,:lineitem_id => ['201'])



#----------------------------------------------7. PROMOTED TWEETS LIST------------------------------------------------------------
#Enable the last line in this block to get a list of promoted tweets for each account. input parametes are given in form of Hash object {}
#INPUT PARAMTERS :
#        :account_id =>'' (required)
#        :json       => boolean (optional)(if true then produce a json response files in local directory)
#Bydefault csv files are produced for each endpoint

#client.promoted_tweets.list_promoted_tweets(:account_id => '1h1e35',:json =>true)



#----------------------------------------------8. PROMOTED TWEETS STATS------------------------------------------------------------
#Enable the last line in this block to get a list of promoted tweets for each account. input parametes are given in form of Hash object {}
#INPUT PARAMTERS :
#        :account_id =>'' (required)
#        :id         =>[] (an array of ids required ,we got this value from promoted_tweets list end point)
#        :json       => boolean (optional)(if true then produce a json response files in local directory)
#Bydefault csv files are produced for each endpoint

#client.stats.stats_promoted_tweets(:account_id => '1h1e35',:id => ['2doz'], :start_date => '2015-01-01',:end_date =>'2015-01-20',:json =>true)
