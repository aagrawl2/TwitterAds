# encoding: UTF-8


module Helpers

	class << self

		def connect_s3(config={})
			Helpers::S3.new(config)
		end

		def connect_ADS(config={})
			Helpers::ADS.new(config)
		end

	end
end

require_relative 'helpers/S3'
require_relative 'helpers/delete_files'
require_relative 'helpers/ADS'