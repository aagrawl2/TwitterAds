# encoding: UTF-8


module GoodDataTwitterAds

	class << self

		def client(config={})
			GoodDataTwitterAds::Client.new(config)
		end

		alias :connect :client
	end
end

require_relative 'gooddata_twitterads/client'