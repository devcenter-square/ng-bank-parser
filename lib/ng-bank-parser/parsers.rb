module NgBankParser
	class Parsers
		$Parsers = [{
			key: "gtb",
			format: "xls",
			name: "Guaranty Trust Bank",
			valid: "lib/ng-bank-parser/fixtures/gtb-excel-valid.xls",
			invalid: "lib/ng-bank-parser/fixtures/gtb-excel-invalid.xlsx"
		}]
	end
end