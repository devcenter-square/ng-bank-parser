require 'pdf-reader-turtletext'

module NgBankParser
	module FirstbankPdfHelpers

		@@pdf_reader = nil
		@@pdf_page_count = nil
		@@account_data = nil
		@@raw_transactions = [[]]

		def has_encryption? path
			begin
				@@pdf_reader = PDF::Reader::Turtletext.new(path)
				@@pdf_page_count = PDF::Reader.new(path).page_count
				false
			rescue PDF::Reader::EncryptedPDFError
				true
			end
		end


		def get_account_data_section
			data = @@pdf_reader.bounding_box do
				page 1
				above "Withdrawal"
			end
			@@account_data = data.text
		end


		def get_all_transaction_rows
			(1..@@pdf_page_count).each do |page|
				@@raw_transactions += get_transactions_table_section page
			end
			@@raw_transactions
		end


		def get_transactions_table_section page_num
			rows = @@pdf_reader.bounding_box do
					page page_num
					below "TransDate"
				end
			rows.text
		end


		def contains_transactions_table?
			@@raw_transactions
		end


		def contains_account_data?
			get_account_data_section
		end


		def get_account_number
			@@account_data.each do |data_item|
				return data_item[1] if data_item[0].start_with? 'Account No'
			end
		end


		def get_account_name
			@@account_data.each do |data_item|
				return data_item[1] if data_item[0].start_with? 'Account Name'
			end
		end


		def get_last_balance
			@@account_data.each do |data_item|
				return data_item[3].to_i if data_item[0].start_with? 'Account Type'
			end
		end


		def get_statement_period
			@@account_data.each do |data_item|
				return data_item[1].split('to') if data_item[0].start_with? 'For the Period of'
			end
		end


		def is_transaction_row? row
			 row[0] =~ /(\d\d-[a-zA-Z]{3}-\d\d)/
		end


		def is_row_invalid? row
			row.length == 0 ||
			row[0].start_with?('END OF STATEMENT') ||
			row[0] == ('Balance B/F') ||
			row[0].start_with?('Page')
		end


		def error_message msg
			return {
					status: 0,
					message: msg
				}
		end


		def send_response data
			return {
					status: 1,
					data: data
				}
		end
	end
end
