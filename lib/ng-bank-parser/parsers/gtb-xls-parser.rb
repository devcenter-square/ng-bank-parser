module NgBankParser
	class GtbXls
		def self.parse(state)
			invalid = {
				status: 0
			}
			valid = {
				status: 1,
				data: {
					bank_name: "Guaranty Trust Bank",
					account_number: "01234567",
					account_name: 'Aikomo Onaopemipo',
					from_date: Date.today,
					to_date: Date.today,
					transactions: [{
						date: Date.today,
						type: "credit",
						amount: 10000,
						ref: "1234",
						remarks: "Some test transaction"
					}]
				}
			}

			if(state == 'invalid')
				return invalid
			else
				return valid
			end
		end
	end
end