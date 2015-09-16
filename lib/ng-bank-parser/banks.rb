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
		    key: "uba",
		    name: "United Bank for Africa",
		    parsers: [{
					format: "pdf",
					valid: "lib/ng-bank-parser/fixtures/uba-pdf-valid.pdf",
					invalid: "lib/ng-bank-parser/fixtures/uba-pdf-invalid.pdf",
					extensions: ["pdf"]
				}]
		  },{
				 key: "firstbank",
				 name: "First Bank",
				 parsers: [{
						 format: "pdf",
						 valid: "lib/ng-bank-parser/fixtures/firstbank-pdf-valid.pdf",
						 fixture_password: 19856,
						 invalid: "lib/ng-bank-parser/fixtures/firstbank-pdf-invalid.pdf",
						 extensions: ["pdf"]
				 }]
		 	},{
				 key: "accessbank",
				 name: "Access Bank Plc",
				 parsers: [{
						 format: "pdf",
						 valid: "lib/ng-bank-parser/fixtures/accessbank-pdf-valid.pdf",
						 invalid: "lib/ng-bank-parser/fixtures/accessbank-pdf-invalid.pdf",
						 extensions: ["pdf"]
				 }]
	  	}
		]
	end
end
