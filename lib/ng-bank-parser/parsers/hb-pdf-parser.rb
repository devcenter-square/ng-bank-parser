require 'pdf-reader'
require 'open-uri'
require_relative 'hb-pdf-parser/hb_transaction_helpers'

module NgBankParser
  class HbPdf

    extend HbTransactionHelpers

    class << self
      def parse(url, password = nil)
        unless ACCEPTED_FORMATS.include? File.extname(url)
          return INVALID_FILE_FORMAT_STRING
        end

        file = open(url)

        @reader = PDF::Reader.new(file)

        if pdf_is_valid? file
          generate_parse

          return account_statement_payload
        else
          return invalid_payload
        end
      end

      private

      def generate_parse
        set_account_name
        set_account_number
        set_end_date
        set_start_date
        extract_transactions
      end

      def extract_transactions
        @transactions = []

        @reader.pages.each do |page|
          page.text.remove_empty_lines.lines.each do |line|
            transaction_items_list = transaction_items(line)
            if transaction_items_list[TRANSACTION_DATE_INDEX].is_date?
              if transaction_is_a_debit?(transaction_items_list, line)
                create_transaction(line, 'debit')
              elsif transaction_is_a_credit?(transaction_items_list, line)
                create_transaction(line, 'credit')
              end
            end
          end
        end
      end

      def account_statement_payload
        return {
            status: VALID_ACCOUNT_STATUS,
            data: {
                bank_name: NgBankParser::Banks::BANK_DEFINITIONS[1][:name],
                account_number: @account_number,
                account_name: @account_name,
                from_date: @start_date,
                to_date: @end_date,
                transactions: @transactions
            }
        }
      end

      def invalid_payload
        {status: INVALID_ACCOUNT_STATUS,
         message: INVALID_ACCOUNT_STATEMENT}
      end
    end
  end
end
