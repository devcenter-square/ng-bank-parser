require 'nokogiri'
require 'roo'
require 'date'

class Hash
  def without(*keys)
    cpy = self.dup
    keys.each { |key| cpy.delete(key) }
    cpy
  end
end

class String
	def convert_to_number
		self.to_s.scan(/\b-?[\d.]+/).join.to_f
	end
	def return_first_number
		self.scan(/\d+/)[0]
	end
	def convert_string_to_date
		date_string = self.scan(/.....\d*..\d{4}/)[0]
		Date.strptime(date_string,"%d/%b/%Y")
	end
	def get_date_strings
		self.scan(/.....\d*..\d{4}/)
	end
end


module GtbExcelHelpers
	def read_file_contents(path)
		if (File.extname(path) == '.xls')
			contents = Nokogiri::HTML(open(path))
			if has_transactions_table(contents)
				{type: "html", contents: contents}
			else 
				{ type: "unknown" }
			end
		else
			contents = Roo::Excelx.new(path)
			{type: "xls", contents: contents}
		end
	end

	def has_transactions_table(contents)
		contents.css("#dgtrans")		
	end

	def get_transactions_from_html(file)
		extract_transaction_rows_from_html(file)
		convert_html_rows_to_transactions
	end

	def extract_transaction_rows_from_html(file)
		@rows = file.xpath('//table[@id="dgtrans"]/tr') # Get transaction table
		@rows.shift # Remove header row
	end

	def convert_html_rows_to_transactions
		transactions = @rows.collect do |row|
			transaction = {}
			[
				[:date, 'td[1]/text()'], #date
				[:ref, 'td[2]/text()'], #ref
				[:debit, 'td[4]/text()'], #debit
				[:credit, 'td[5]/text()'], #credit
				[:balance, 'td[6]/text()'], #balance
				[:remarks, 'td[7]/text()'], #remarks
			].each do |column_name, xpath|
				integer_columns = [:debit, :credit, :balance]
				column_value = row.at_xpath(xpath).text()

				# If it's an integer field convert to number
				if integer_columns.include?(column_name)
					column_value = column_value.convert_to_number;
				end
				
				transaction[column_name] = column_value				
				transaction[:date] =  Date.strptime(column_value,"%d-%b-%Y") if column_name == :date
			end

			filter_debit_or_credit(transaction)
        end
        filter_invalid(transactions)
	end

	def filter_invalid(transactions)
		transactions.select do |row|
			is_valid_transaction(row)
		end
	end

	def filter_debit_or_credit(transaction)
		if (transaction[:debit].nil? || transaction[:debit] == 0)
			transaction[:type] = "credit"
			transaction[:amount] = transaction[:credit]
		else
			transaction[:type] = "debit"
			transaction[:amount] = transaction[:debit]
		end

		# Remove credit and debit keys
    	transaction.without(:debit, :credit)
	end

	def get_transactions_from_excel(file)
		transactions = []
        file.each(date: 'Trans Date', ref: 'Reference', debit: 'Debit', credit: 'Credit', balance: 'Balance', remarks: 'Remarks') do |row|
  			if is_valid_transaction(row)
  				transaction = filter_debit_or_credit(row)
  				transaction[:ref] = transaction[:ref].to_s
  				transactions << transaction
  			end
		end
		transactions
	end

	def is_valid_transaction(row)
		return row[:date].is_a?(Date) && (row[:amount] || row[:credit] || row[:debit]).is_a?(Float) && row[:balance].is_a?(Float) && !row[:remarks].empty?
	end
end