require_relative "ng-bank-parser/version"
require_relative "ng-bank-parser/banks"
require_relative "ng-bank-parser/router"
require_relative "ng-bank-parser/pdf-unlocker"
require_relative "ng-bank-parser/parsers/gtb-excel-parser"
require_relative "ng-bank-parser/parsers/uba-pdf-parser"
require_relative "ng-bank-parser/parsers/hb-pdf-parser"
require_relative "ng-bank-parser/parsers/firstbank-pdf-parser"
require_relative "ng-bank-parser/parsers/accessbank-pdf-parser"
require_relative "ng-bank-parser/parsers/ecobank-pdf-parser"

module NgBankParser
  # Your code goes here...
  file_path = '/Users/onyekachi/dev/ruby/ng-bank-parser/lib/ng-bank-parser/fixtures/ecobank-pdf-valid.pdf'
  @parser = NgBankParser::Router.parse("ecobank", file_path)
end
