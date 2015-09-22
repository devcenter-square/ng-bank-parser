require 'pdf-reader'
require 'open-uri'
require_relative 'accessbank-pdf-parser/helpers'
require_relative '../pdf-unlocker.rb'

module NgBankParser
	class AccessbankPdf
    extend AccessbankPdfHelpers

		def self.parse(path, password=nil)

      unless File.extname(path) == '.pdf'
        return error('This file format is not supported yet. Please try uploading a pdf')
      end

      @pdf = open_pdf(path, password)

      if @pdf
        pdf_as_array = pdf_to_a(@pdf)

        unless has_valid_details?(pdf_as_array)
          return error("Couldn't fetch account details from pdf")
        end

        response =  get_details(pdf_as_array)
        return success(response)
      else
        return error("Couldn't open the pdf file passed")
      end
    end



    def self.open_pdf(path, password)
      begin
        file =  open(path)
        @pdf = PDF::Reader.new(file)
      rescue PDF::Reader::EncryptedPDFError
        if password
          return unlock_pdf(path, password)
        else
          return nil
        end
      rescue
        return nil
      end
    end


    def self.unlock_pdf(path, password)
        unlocker = PDFUnlocker.new
        response = unlocker.unlock(path, password)

        return nil unless response

        if response.include? 'Unlock Failed'
          return nil
        else
          temp = StringIO.new
          temp.write(response)
          return PDF::Reader.new(temp)
        end
    end

	end
end
