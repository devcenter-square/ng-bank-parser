require_relative 'gtb-excel-parser/helpers'

module NgBankParser
	class GtbExcel
		extend GtbExcelHelpers

		class << self
			def parse(path, password = nil)
				accepted_formats = [".xls",".xlsx"];
				unless accepted_formats.include? File.extname(path)
					return error_message("Invalid file format")
				end

				file = read_file_contents(path)
				if (file[:type] == "html")
					html_parse(file[:contents])
				elsif (file[:type] == "xls")
					xls_parse(file[:contents])
				else
					return error_message("Could not parse this file")
				end
			end

			def html_parse(file)
				data = {}

		        data[:transactions] = get_transactions_from_html(file)
		        data[:account_number] = file.css("#lblAcctNo").text().return_first_number
		        data[:from_date] = file.css("#lblPeriod1").text().convert_string_to_date
		        data[:to_date] = file.css("#lblPeriod2").text().convert_string_to_date
		        data[:account_name] = file.css("#lblAcctName").text()
		        data[:bank_name] = "Guaranty Trust Bank"

		       	send_response(data)
			end

			def xls_parse(file)
				data = {}

				data[:transactions] = get_transactions_from_excel(file)
		        data[:account_number] = file.row(10)[0].return_first_number
		        date_strings = file.row(14)[0].get_date_strings
		        data[:from_date] = date_strings[0].convert_string_to_date
		        data[:to_date] = date_strings[1].convert_string_to_date
		        data[:account_name] = file.row(5)[0]
		        data[:bank_name] = "Guaranty Trust Bank"

				send_response(data)
			end

			def error_message(text)
				return { 
					status: 400,
					message: text
				}
			end

			def send_response(data)
				return {
					status: 200,
					data: data
				}
			end
		end
	end
end