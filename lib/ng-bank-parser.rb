require "ng-bank-parser/version"
require "ng-bank-parser/banks"
require "ng-bank-parser/router"
require "ng-bank-parser/pdf-unlocker"
require "ng-bank-parser/parsers/gtb-excel-parser"
require "ng-bank-parser/parsers/uba-pdf-parser"
require "ng-bank-parser/parsers/accessbank-pdf-parser"

module NgBankParser
  # Your code goes here...

  AccessbankPdf.parse('lib/ng-bank-parser/fixtures/accessbank-pdf-valid.pdf')

end
