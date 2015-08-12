require 'pdf-reader-turtletext'
require 'date'
require_relative 'firstbank-pdf-parser/helpers'

module NgBankParser
	class FirstbankPdf
		extend Helpers
		@@transactions = []
		def self.parse(path)
			accepted_formats = [".pdf"];
			unless accepted_formats.include? File.extname(path)
				return { status: 0, message: "Invalid file format" }
			end

			if has_encryption? path 
				return { status: 0, message: "Invalid file format" }
			end 

			if contains_account_data?
				@@account_name = get_account_name
				@@account_number = get_account_number
				@@last_balance = get_last_balance
				@@from_date, @@to_date = get_statement_period
			else
				return { status: 0, message: "Invalid file format" }
			end

			unless @@account_name && @@account_number && @@last_balance
				return { status: 0, message: "Invalid file format" }
			end
			
			raw_transactions = get_all_transaction_rows
			if contains_transactions_table?
				extract_transactions(clean(raw_transactions))
				File.open('transactions.txt', 'w') { |file| file.write(@@transactions) }
				return {
					status: 1,
					data: {
						bank_name: "First Bank",
						account_number: @@account_number,
						account_name: @@account_name,
						from_date: Date.strptime(@@from_date.strip,"%d-%b-%Y"),
						to_date: Date.strptime(@@to_date.strip,"%d-%b-%Y"),
						transactions: @@transactions
				}
			}
			else
				return { status: 0, message: "Invalid file format" }
			end
		end


		private

		def self.extract_transactions(jagged_array = [[]])
			jagged_array.each_with_index do |array, index|
				if array[0] =~ /(\d\d-[a-zA-Z]{3}-\d\d)/ 
					transaction = {}
					transaction[:ref] = ''
					transaction[:date] = Date.strptime(array[0], '%d-%b-%y')
					transaction[:remarks] = array[1]
					transaction[:amount] = array[3].delete(',').to_f
					transaction[:balance] = array[4].delete(',').to_f
					if transaction[:balance].to_i > @@last_balance
						transaction[:type] = 'credit'
					else
						transaction[:type] = 'debit'
					end
					@@transactions << transaction
				else
					@@transactions.last[:remarks] += array[0]
				end
			end
		end


		def self.clean(jagged_array = [[]])
			jagged_array.reject! do |array|
				if ( array.length == 0 || 
					array[0].start_with?('END OF STATEMENT') || 
					array[0].start_with?('Balance B/F') || 
					array[0].start_with?('Page'))
					true
				else
					false
				end
			end
		end	

	end
end