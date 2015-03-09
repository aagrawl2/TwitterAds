require 'sequel'
require 'jdbc/dss'

Jdbc::DSS.load_driver
Java.com.gooddata.dss.jdbc.driver.DssDriver


class Helpers::ADS

	def initialize(config={})
		@username         = config.delete(:username)
		@password         = config.delete(:password)
		@ads_instance_url = config.delete(:ads_instance_url)

		if @username=='' || @username.nil?
			raise ArgumentError, "username is either empty string or contains no values"
		elsif @password=='' || @password.nil?
			raise ArgumentError, "password is either empty string or contains no values"
		elsif @ads_instance_url=='' || @ads_instance_url.nil?
			raise ArgumentError, "ads_instance_url is either empty string or contains no values"
		end
	end
#-----------------------------------------------------WRITE TO ADS ------------------------------------------------------------------
	# This function will execute an INSERT/COPY/TRUNCATE/DROP query in ADS
	# INPUT PARAMETER --->
	# 		file_name = ''  ( name of csv file)
	# 		query  = '' If you have multiple commands then try to change logic in the function so that it can read it as an array

	def write_data(file_name,query)

		if file_name=='' || file_name.nil? || file_name.empty?
			raise ArgumentError, "File Name is missing"
		elsif query=='' || query.nil?
			raise ArgumentError, "SQL QUERY IS MISSING OR EMPTY"
		end

		#PUSH THE CSV FILE INTO ADS
		Sequel.connect @ads_instance_url, :username => @username, :password => @password do |conn|
		  results = conn.run (query) 
		end
	end

end
