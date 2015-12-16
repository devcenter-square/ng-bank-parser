require 'pdf-reader'
require_relative 'firstbank-pdf-parser/helpers'


module NgBankParser
	class FirstbankPdf
		extend FirstbankPdfHelpers

		def self.parse(path, password = nil)
			accepted_formats = [".pdf"];
			unless accepted_formats.include? File.extname(path)
				return error_message 'Invalid file format'
			end

			file = open(path)

			if has_encryption? file
				if password
					unless get_unlocked_pdf? path, password
						return error_message 'Password supplied for decryption is invalid.'
					end
				else
					return error_message 'PDF File is encrypted and no password was supplied'
				end
			end

			unless contains_account_data?
				return error_message 'Unable to read account details'
			end

			raw_transactions = contains_transactions_table?
			if raw_transactions
				bdd = extract_transactions(clean(raw_transactions))
				data = {}
				data[:bank_name] = 'First Bank'
				data[:account_number] = get_account_number
				data[:account_name] = get_account_name
				data[:from_date] = get_from_date
				data[:to_date] = get_to_date
				data[:transactions] = bdd
				send_response data
			else
				return error_message 'Could not find any transactions'
			end
		end

		private

		def self.extract_transactions(jagged_array = [[]])
			arr = []
			jagged_array.each do |array|
				if is_transaction_row? array
					transaction = {}
					transaction[:ref] = ''
					transaction[:date] = Date.strptime(array[0], '%d-%b-%y')
					transaction[:remarks] = array[1]
					transaction[:amount] = array[3].delete(',').to_f
					transaction[:balance] = array[4].delete(',').to_f
					if transaction[:balance].to_i > get_last_balance
						transaction[:type] = 'credit'
						update_last_balance transaction[:balance]
					else
						transaction[:type] = 'debit'
						update_last_balance transaction[:balance]
					end
					arr << transaction
				else
					arr.last[:remarks] += array[0]
				end
			end
			arr
		end


		def self.clean(jagged_array = [[]])
			jagged_array.reject! do |array|
				is_row_invalid? array
			end
		end

	end
end
