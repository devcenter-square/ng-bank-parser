require 'httmultiparty' 

module NgBankParser
	class PDFUnlocker
		include HTTMultiParty
		base_uri 'http://pdf-unlocker.herokuapp.com'

		def initialize(file, password)
			@pdf = file
			@password = password
		end

		def unlocked_pdf
			options = { :pdf => @pdf, :password => @password }
			begin
				response = self.class.post('/rest/pdf/unlock', :query => options, :detect_mime_type => true).parsed_response
			rescue StandardError
				response = nil
			end
		end

	end
end
