module NgBankParser
  require 'active_support/core_ext/hash'

  class Router
    @banks = NgBankParser::Banks::BANK_DEFINITIONS.with_indifferent_access
    
    #this takes our bank parser along with the bank name supplied from the payload so as to compare
    #and see if the file extension is available for that bank
    #it returns harsh or the necessary status message
    def self.parse(bank_key, path, password = nil)

      selected_bank = @banks[bank_key]
      return {status: 0, message: 'Your bank is not yet supported'} unless selected_bank

      extension_name = File.extname(path).delete('.')
      parser = selected_bank[:parsers][extension_name]

      if parser
        parse_with(parser, bank_key, path, password)
      else
        return {status: 0, message:"The '.#{extension_name}' file format is not supported for this bank (#{selected_bank[:name]})."}
      end
    end

    private

    #Builds the the parser to use from the name and file format of the uploaded file
    def self.parse_with(parser, bank_key, path, password)
      class_name = bank_key.capitalize + parser.capitalize
      class_object = NgBankParser.const_get(class_name)
      class_object.parse(path, password)
    end
  end
end