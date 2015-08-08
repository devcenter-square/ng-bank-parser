require './banks'
require './parsers/gtb-excel-parser.rb'

module NgBankParser
  class Router
    #Bank hash
    @bank_stash = $Banks
    #The holder for our supported file extensions
    @file_extension_array = []
    #The variable that holds the location index for a searched bank in the Bank hash
    @value
    
    
    #this takes our bank parser along with the bank name supplied from the payload so as to compare
    #and see if the file extension is available for that bank
    #it's result is to fill up the @file_extension_array with the supported bank extensions
    def self.router(bank_name, filename)
      @value = @bank_stash.index {|x| x[:key] == bank_name}
      
      if @value.nil?
        return {status: 0, message: "Your bank is not yet supported"}
      else
        @file_extension_array += @bank_stash[@value][:parsers].map {|e| e[:extensions]}

        parser_picker(filename)
      end      
    end


    private

    #this uses the extension in the file of the uploaded payload to check support in @file_extension_array
    #and goes on to pick the parser to use for the operation
    def self.parser_picker(filename)
      extension_name = File.extname(filename).delete('.')
      if @file_extension_array.reduce(:concat).include?(extension_name)
          ng_bank_parsers(filename)
      else
          return {status: 0, message:"The '.#{extension_name}' file format is not supported for your bank."}
      end         
    end

    #Builds the the parser to use from the name and file format of the uploaded file
    def self.ng_bank_parsers(filename)
      key = @bank_stash[@value][:key].capitalize
      format = @bank_stash[@value][:parsers].map { |e| e[:format].capitalize }
      class_name = key + format.reduce(:concat)
      NgBankParser.const_get(class_name).parse(filename)
    end

  end
end