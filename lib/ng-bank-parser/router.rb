module NgBankParser
  class Router
    @banks = NgBankParser::Banks::BANK_DEFINITIONS
    
    #this takes our bank parser along with the bank name supplied from the payload so as to compare
    #and see if the file extension is available for that bank
    #it's result is to fill up the @supported_extension_array with the supported bank extensions
    def self.parse(bank_key, path, password = nil)
      @path = path
      @password = password
      @selected_bank = @banks.find {|x| x[:key] == bank_key}
      
      if @selected_bank.nil?
        return {status: 0, message: "Your bank is not yet supported"}
      else
        extensions = @selected_bank[:parsers].map {|e| e[:extensions]}
        @supported_extensions = extensions.reduce(:concat)
        pick_parser()
      end      
    end

    private

    #this uses the extension in the file of the uploaded payload to check support in @supported_extension_array
    #and goes on to pick the parser to use for the operation
    def self.pick_parser()
      bank_name = @selected_bank[:name]
      extension_name = File.extname(@path).delete('.')

      if @supported_extensions.include? extension_name
          parser = @selected_bank[:parsers].find {|p| p[:extensions].include? extension_name}
          parse_with(parser)
      else
          return {status: 0, message:"The '.#{extension_name}' file format is not supported for this bank (#{bank_name})."}
      end         
    end

    #Builds the the parser to use from the name and file format of the uploaded file
    def self.parse_with(parser)
      class_name = @selected_bank[:key].capitalize + parser[:format].capitalize
      class_object = NgBankParser.const_get(class_name)
      parser_response = class_object.parse(@path, @password)
    end

  end
end