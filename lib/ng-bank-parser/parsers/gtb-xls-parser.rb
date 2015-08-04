module NgBankParser
	class GtbXls
		def self.parse
			return {
				bank_name: "Guaranty Trust Bank",
				account_number: 01234567,
				account_name: 'Aikomo Onaopemipo',
				from_date: Date.today,
				to_date: Date.today,
				transactions: []
			}
		end
	end
end