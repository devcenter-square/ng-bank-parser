module NgBankParser
  class Router
    @banks_hash = $Banks
    @supported_extension_array = []
    @selected_bank_index
    
    #this takes our bank parser along with the bank name supplied from the payload so as to compare
    #and see if the file extension is available for that bank
    #it's result is to fill up the @supported_extension_array with the supported bank extensions
    def self.parse(bank_name, path, password = nil)
      @password = password;
      @selected_bank_index = @banks_hash.index {|x| x[:key] == bank_name}
      
      if @selected_bank_index.nil?
        return {status: 0, message: "Your bank is not yet supported"}
      else
        @supported_extension_array += @banks_hash[@selected_bank_index][:parsers].map {|e| e[:extensions]}
        parser_picker(path)
      end      
    end

    private

    #this uses the extension in the file of the uploaded payload to check support in @supported_extension_array
    #and goes on to pick the parser to use for the operation
    def self.parser_picker(path)
      extension_name = File.extname(path).delete('.')
      if @supported_extension_array.reduce(:concat).include?(extension_name)
          ng_bank_parsers(path)
      else
          return {status: 0, message:"The '.#{extension_name}' file format is not supported for your bank."}
      end         
    end

    #Builds the the parser to use from the name and file format of the uploaded file
    def self.ng_bank_parsers(path)
      key = @banks_hash[@selected_bank_index][:key].capitalize
      format = @banks_hash[@selected_bank_index][:parsers].map { |e| e[:format].capitalize }
      class_name = key + format.reduce(:concat)
      NgBankParser.const_get(class_name).parse(path, @password)
    end

  end
end