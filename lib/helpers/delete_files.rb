require 'fileutils'

module Helpers

	def delete_files(file_names)

		if file_names.nil? || file_names=='' || file_names.empty?
			raise ArgumentError, "file_names is either empty or contains no values"
		end
		if file_names.is_a ? Array
			file_names.each { |f|
				path = File.join(Dir.pwd,name)
				File.delete(path) if f!='.' && f!='..'
				puts "Files successfully Deleted"
				}
		else
			path = File.join(Dir.pwd,name)
			File.delete(path) if f!='.' && f!='..'
			puts "Files successfully Deleted"
		end
	end
end

