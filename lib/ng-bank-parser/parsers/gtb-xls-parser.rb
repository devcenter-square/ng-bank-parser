require 'nokogiri'

class Hash
  def without(*keys)
    cpy = self.dup
    keys.each { |key| cpy.delete(key) }
    cpy
  end
end

module NgBankParser
	class GtbXls
		def self.parse(path)
			accepted_formats = [".xls"];
			unless accepted_formats.include? File.extname(path)
				return { status: 0, message: "Invalid file format" }
			end

			@file = Nokogiri::HTML(open(path))
			rows = @file.xpath('//table[@id="dgtrans"]/tr')
			rows.shift

	        transactions = rows.collect do |row|
				transaction = {}
				[
					[:date, 'td[1]/text()'], #date
					[:ref, 'td[2]/text()'], #ref
					[:debit, 'td[4]/text()'], #debit
					[:credit, 'td[5]/text()'], #credit
					[:balance, 'td[6]/text()'], #balance
					[:remarks, 'td[7]/text()'], #remarks
				].each do |name, xpath|
					integers = [:debit, :credit, :balance]
					val = row.at_xpath(xpath).text()

					if integers.include?(name)
						val = val.to_s.scan(/\b-?[\d.]+/).join.to_f
					end
					
					transaction[name] = val

					if (name == :date)
						transaction[:date] =  Date.strptime(val,"%d-%b-%Y")
					end
				end
	            
				if (transaction[:debit].nil? || transaction[:debit] == 0)
					transaction[:type] = "credit"
					transaction[:amount] = transaction[:credit]
				else
					transaction[:type] = "debit"
					transaction[:amount] = transaction[:debit]
				end

	        	transaction.without(:debit, :credit)
	        end

	        @account = @file.css("#lblAcctNo").text().scan(/\d+/)[0]
	        dateString = @file.css("#lblPeriod1").text() + @file.css("#lblPeriod2").text()
	        @dates = dateString.scan(/.....\d*..\d{4}/)
	        @name = @file.css("#lblAcctName").text()
	        @address = @file.css("#lblAddress").text()

			return {
				status: 1,
				data: {
					bank_name: "Guaranty Trust Bank",
					account_number: @account,
					account_name: @name,
					from_date: Date.strptime(@dates[0],"%d/%b/%Y"),
					to_date: Date.strptime(@dates[1],"%d/%b/%Y"),
					transactions: transactions
				}
			}
		end
	end
end