require 'rest-client' 

module NgBankParser
	class PDFUnlocker

		def self.unlock(path, password)
			@path = path
			@password = password

			if File.exists? @path
				unlock_pdf_file
			else				
				unlock_pdf_url
			end
		end

		def self.unlock_pdf_file
			url = 'http://pdf-unlocker.herokuapp.com/rest/pdf/unlock'

			begin
				response = RestClient.post url, {:password => @password, :pdf => File.new(@path, 'rb')}
			rescue
				response = nil
			end
		end

		def self.unlock_pdf_url
			url = 'http://pdf-unlocker.herokuapp.com/rest/pdf/unlock_with_file_url'

			begin
				response = RestClient.post url, {:password => @password, :file_url => @path, :multipart => true}
			rescue
				response = nil
			end
		end

	end
end
