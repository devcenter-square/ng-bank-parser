require 'pdf-reader'
require 'date'
require 'open-uri'
require_relative 'statement_utils'
require_relative '../../pdf-unlocker.rb'

module NgBankParser
	module FirstbankPdfHelpers
		include StatementUtils

		@@pdf_reader = nil
		@@account_name = nil
		@@account_number = nil
		@@last_balance = nil
		@@statement_period = nil
		@@from_date = nil
		@@to_date = nil

		def has_encryption? file
			begin
				@@pdf_reader = PDF::Reader.new(file)
				false
			rescue PDF::Reader::EncryptedPDFError
				true
			end
		end

		def get_unlocked_pdf? path, password
			response = PDFUnlocker.unlock(path, password)
			return false unless response
			if response.include? 'Unlock Failed'
				return false
			else
				pseudo_file = StringIO.new
				pseudo_file.write(response)
				begin
					@@pdf_reader = PDF::Reader.new(pseudo_file)
					return true
				rescue
					return false
				end
			end
		end


		def get_transaction_data
			pages = get_pages @@pdf_reader
			get_all_transactions(pages)
		end


		def get_account_data
			lines = get_first_page_text @@pdf_reader
	  		lines.each do |line|
				if line[0].start_with? 'Account No:'
			 		set_account_number line
			  		set_last_balance line
				elsif line[0].start_with? 'Account Name:'
			  		set_account_name line
				elsif line[0].start_with? 'For the Period of:'
			  		set_statement_period line
				end
			end
		end


		def get_account_number
			@@account_number
		end


		def get_account_name
			@@account_name
		end


		def get_last_balance
			@@last_balance.to_i
		end

		def get_from_date
			Date.strptime(@@from_date.strip,"%d-%b-%Y")
		end


		def get_to_date
			Date.strptime(@@to_date.strip,"%d-%b-%Y")
		end


		def contains_transactions_table?
			get_transaction_data
		end


		def contains_account_data?
			get_account_data
			@@account_name && @@account_number && @@last_balance && @@statement_period
		end


		def set_account_number line
			@@account_number = line[1] unless line[1].blank?
		end


		def set_account_name line
			@@account_name = line[1] unless line[1].blank?
		end


		def set_last_balance line
			@@last_balance = line[2] unless line[1].blank?
		end


		def update_last_balance balance
			@@last_balance = balance
		end


		def set_statement_period line
			unless line[1].blank?
				@@statement_period = line[1].split('to')
				@@from_date, @@to_date = @@statement_period
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
					status: 400,
					message: msg
				}
		end


		def send_response data
			return {
					status: 200,
					data: data
				}
		end


		private

		def get_all_transactions pages
			raw_transactions = [[]]
			pages.each do |page|
				page_text = get_page_text page
				index = get_transaction_table_index page_text
				unless index == -1
					lines = page_text[index..-1]
					lines.each do |line|
						raw_transactions << line.strip.split(/\s\s+/)
					end
				end
			end
			return raw_transactions
		end

	end
end
