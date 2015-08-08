module NgBankParser
  class Banks
    $Banks = [{
                  key: "gtb",
                  name: "Guaranty Trust Bank",
                  parsers: [{
                                format: "excel",
                                valid: "lib/ng-bank-parser/fixtures/gtb-excel-valid.xls",
                                invalid: "lib/ng-bank-parser/fixtures/gtb-excel-invalid.xlsx",
                                extensions: ["xls"]
                            }]
              }, {
                  key: "uba",
                  name: "United Bank for Africa",
                  parsers: [{
                                format: "pdf",
                                valid: "lib/ng-bank-parser/fixtures/uba-pdf-valid.pdf",
                                invalid: "lib/ng-bank-parser/fixtures/uba-pdf-invalid.pdf",
                                extensions: ["pdf"]
                            }]
              }]
  end
end