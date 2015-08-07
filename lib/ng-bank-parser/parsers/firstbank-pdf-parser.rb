require 'pdf-reader-turtletext'
require 'date'

module NgBankParser
	class FirstbankPdf
		@@transactions = []
		def self.parse(path)
			accepted_formats = [".pdf"];
			unless accepted_formats.include? File.extname(path)
				return { status: 0, message: "Invalid file format" }
			end

			begin
				reader = PDF::Reader::Turtletext.new(path)
				page_count = PDF::Reader.new(path).page_count
			rescue PDF::Reader::EncryptedPDFError
				return { status: 0, message: "PDF File is Encrypted." }
			end

			raw_transactions = [[]]
			
			# section of pdf that contains general data like account number, 
			# account name, opening balance and time period
			data = reader.bounding_box do
				page 1
				above "Withdrawal"
			end
			data.text.each_with_index do |item , index|
				unless item.length == 1 #if length is 1, it's probably an array with an empty string
					if item[0] and item[0].start_with? 'Account No'
						@@account_number = item[1]
					elsif item[0] and item[0].start_with? 'Account Type'
						@@last_balance = item[3].to_i
					elsif item[0] and item[0].start_with? 'Account Name'
						@@account_name = item[1]
					elsif item[0] and item[0].start_with? 'For the Period of'
						date_range = item[1]
						@@from_date = date_range.split('to')[0].strip
						@@to_date = date_range.split('to')[1].strip
					else
						next
					end
				end
			end
			return { status: 0, message: "Unable to parse file" } if @@account_number.nil? || @@last_balance.nil?
			
			(1...page_count).each do |page_num|
				# section of pdf that contains the table of
				# transactions
				rows = reader.bounding_box do
					page page_num
					below "TransDate"
				end
				raw_transactions += rows.text
			end
			
			extract_transactions(clean(raw_transactions))
			File.open('transactions.txt', 'w') { |file| file.write(@@transactions) }
			return {
				status: 1,
				data: {
					bank_name: "First Bank",
					account_number: @@account_number,
					account_name: @@account_name,
					from_date: Date.strptime(@@from_date,"%d-%b-%Y"),
					to_date: Date.strptime(@@to_date,"%d-%b-%Y"),
					transactions: @@transactions
				}
			}
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