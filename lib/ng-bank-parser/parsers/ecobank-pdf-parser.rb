require 'pdf-reader'
require 'open-uri'
require_relative 'ecobank-pdf-parser/helpers'

module NgBankParser
  class EcobankPdf
    extend EcobankPdfHelpers

    FILE_FORMATS = [".pdf"]
    
    def self.parse(path, password=nil) 
      unless FILE_FORMATS.include? File.extname(path)
        return error("Invalid file format. Please use one of the following: #{ FILE_FORMATS.each{ |format| format }}")
      end

      file = open(path)
      begin
        @pdf = PDF::Reader.new(file)
      rescue PDF::Reader::EncryptedPDFError
        return error("Invalid file. Please use an unencrypted pdf")
      rescue 
        return error("Couldn't parse this file")
      end

      pdf_array = pdf_to_a(@pdf)

      unless has_valid_details?(pdf_array)
        return error("Couldn't fetch account details from pdf")
      end

      response = get_details(pdf_array)
      return success(response)
    end 
  end
end