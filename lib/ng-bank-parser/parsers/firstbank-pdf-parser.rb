require 'pdf-reader'
require_relative 'firstbank-pdf-parser/helpers'


module NgBankParser
	class FirstbankPdf
		extend FirstbankPdfHelpers

		@@transactions = []

		def self.parse(path)
			accepted_formats = [".pdf"];
			unless accepted_formats.include? File.extname(path)
				return error_message 'Invalid file format'
      end

			if has_encryption? path
				return error_message 'PDF File is encrypted'
			end

			unless contains_account_data?
				return error_message 'Unable to read account details'
			end

			if contains_transactions_table?
				extract_transactions(clean(get_raw_transactions))
				data = {}
				data[:bank_name] = 'First Bank'
				data[:account_number] = get_account_number
				data[:account_name] = get_account_name
				data[:from_date] = get_from_date
				data[:to_date] = get_to_date
				data[:transactions] = @@transactions
				send_response data
			else
				return error_message 'Could not find any transactions'
			end
		end


		private

		def self.extract_transactions(jagged_array = [[]])
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
					@@transactions << transaction
				else
					@@transactions.last[:remarks] += array[0] if @@transactions
				end
			end
		end


		def self.clean(jagged_array = [[]])
			jagged_array.reject! do |array|
				is_row_invalid? array
			end
		end

	end
end
