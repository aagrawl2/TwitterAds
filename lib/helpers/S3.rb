require 'zip'
require 'csv'
require 'aws-sdk'
require 'fileutils'

class Helpers::S3

	def initialize(config={})
		access_key_id        = config.delete(:access_key_id)
		secret_access_key    = config.delete(:secret_access_key)
		puts access_key_id,secret_access_key
		bucket_name 		 = config.delete(:bucket_name)
		if access_key_id=='' || access_key_id.nil?
			raise ArgumentError, "access_key_id is either empty string or contains no values"
		elsif secret_access_key=='' || secret_access_key.nil?
			raise ArgumentError, "secret_access_key is either empty string or contains no values"
		elsif bucket_name=='' || bucket_name.nil?
			raise ArgumentError, "bucket_name is either empty string or contains no values"
		end
		@s3 = AWS::S3.new(:access_key_id => access_key_id, :secret_access_key => secret_access_key)
		@bucket_name = bucket_name
	end

#-----------------------------------------------------UPLOAD TO S3------------------------------------------------------------------
	# This function will upload files to S3 to a particular folder
	# INPUT PARAMETER --->
	# 		:file_name => ''  ( name of file to be uploaded in S3)
	# 		:path_to_s3_folder => '' (Eg. 'AIDAJNUX6HKJ46IXAJFZU_gdc-ms-cust_temp/source/sitecat/visitswithasearch/')
	# 		NOTE : Dont forget to put '/' at the end of the folder name, otherwise it will error out
	def upload(config={})

		file_name         = config.delete(:file_name)
		path_to_s3_folder = config.delete(:path_to_s3_folder)

		if file_name.nil? || file_name.empty?
			raise ArgumentError, "file_names is either empty or contains no values"
		elsif file_name==''
			raise ArgumentError, "File Names is passed as empty string. Pass appropriate values"
		end

		file_names = Array.new
		file_names = file_name if file_name.is_a? Array

		file_names.push(file_name) if file_name.is_a? String
		file_names.each {|file|
			#raise ArgumentError, "File name does not exist in the main directory" if File.exists?(file)==false
			final_file_path = path_to_s3_folder + file
			@s3.buckets[@bucket_name].objects[final_file_path].write(:file => file)
			puts "#{file} successfully uploaded"
		} unless file_names.nil?
	end

end
