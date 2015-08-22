module NgBankParser
	class Banks
		$Banks = [{
		    key: "gtb",
		    name: "Guaranty Trust Bank",
		    parsers: [{
				format: "excel",
				valid: "lib/ng-bank-parser/fixtures/gtb-excel-valid.xlsx",
				invalid: "lib/ng-bank-parser/fixtures/gtb-excel-invalid.pdf",
				extensions: ["xls","xlsx"]
			}]
		  },{
			key: "firstbank",
			name: "First Bank",
			parsers: [{
				format: "pdf",
				valid: "lib/ng-bank-parser/fixtures/firstbank-pdf-valid.pdf",
				invalid: "lib/ng-bank-parser/fixtures/firstbank-pdf-invalid.xlsx",
				extensions: ["pdf"]
			}]
		}]
	end
end