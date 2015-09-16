require 'pdf-reader'
require 'open-uri'
require_relative 'uba-pdf-parser/transaction_tools'


module NgBankParser
  class UbaPdf
    extend TransactionTools

    class << self
      def parse(url, password = nil)
        unless ACCEPTED_FORMATS.include? File.extname(url)
          return invalid_file
        end

        file = open(url)

        if has_encryption? file 
          return invalid_file
        end

        set_up_first_page

        if is_valid_pdf?
          set_account_details
          set_transactions
          return return_payload
        else
          return invalid_file
        end
      end

      private

      def has_encryption? path
        begin
          @reader = PDF::Reader.new(path)
          false
        rescue PDF::Reader::EncryptedPDFError
          true
        end
      end

      def set_up_first_page
        @first_page_text = @reader.pages.first.text.remove_empty_lines
        set_column_positions(@first_page_text.lines[TABLE_HEADER_LINE_INDEX])
      end

      def set_account_details
        set_bank_name
        set_account_name
        set_account_number
        set_dates
        # print_account_details
      end

      def print_account_details
        puts @bank_name
        puts @account_name
        puts @account_number
        puts @from_date
        puts @to_date
      end

      def set_bank_name
        @bank_name = "United Bank for Africa"
      end

      def set_account_name
        account_name_line = @first_page_text.lines[ACCOUNT_NAME_LINE_INDEX]
        @account_name = account_name_line.get_text_between_markers(ACCOUNT_NAME_START_MARKER, ACCOUNT_NAME_END_MARKER)
      end

      def set_account_number
        account_number_line = @first_page_text.lines[ACCOUNT_NUMBER_LINE_INDEX]
        account_number_line_string = account_number_line.remove_white_spaces.downcase!
        @account_number = account_number_line_string.get_text_between_markers(ACCOUNT_NUMBER_STRING, CURRENCY_STRING).upcase!
      end

      def set_dates
        date_line = @first_page_text.lines[1]
        date_line_string = date_line.remove_white_spaces.downcase!
        @from_date = date_line_string.get_text_between_markers(START_DATE_STRING, END_DATE_STRING).upcase!.convert_to_date
        @to_date = date_line_string.get_text_after_marker(END_DATE_STRING).upcase!.convert_to_date
      end


      def return_payload
        return {
            status: 200,
            data: {
                bank_name: @bank_name,
                account_number: @account_number,
                account_name: @account_name,
                from_date: @from_date,
                to_date: @to_date,
                transactions: @transactions_hashes_array
            }
        }
      end

      def invalid_file
        return {
            status: 400, message: INVALID_FILE_STRING
        }
      end

    end
  end
end


