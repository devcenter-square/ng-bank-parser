require 'date'
require 'active_support/core_ext/object/blank'
require_relative 'classes/string'
require_relative 'classes/transaction'
require_relative 'pdf_checks'


module NgBankParser
  module TransactionTools
    include PdfChecks

    private

    def set_transactions
      @transactions = Array.new
      @transaction_strings = Array.new
      @reader.pages[0..-2].each do |page|
        seperate_lines_into_transaction_strings(page.text.remove_empty_lines.lines)
      end
      @transaction_strings.compact!
      @transaction_strings.each do |transaction_string|
        transaction = Transaction.new(transaction_string, @columns)
        @transactions << transaction
      end
      @transactions.shift
      set_transactions_hashes_array
    end

    def set_transactions_hashes_array
      @transactions_hashes_array = []
      @transactions.each do |transaction|
        @transactions_hashes_array << transaction.to_hash
      end
    end

    def seperate_lines_into_transaction_strings(lines)
      @lines = lines[RANGE_OF_LINES_WITH_TRANSACTIONS]
      @lines.each_with_index do |line, index|
        if line_has_date?(line)
          transaction_string = line
          next_lines = get_next_lines(index)
          next_lines.each do |next_line|
            if !line_has_date?(next_line)
              transaction_string = transaction_string + next_line
            else
              break
            end
          end
        end
        @transaction_strings << transaction_string
      end
    end

    def line_has_date?(line)
      line.get_date_string.is_date?
    end

    def get_next_lines(index)
      @lines[index+1..-1]
    end

    def set_column_positions(column_header_line)
      begin
        column_header_line.downcase!
        @date_column = {
            start: column_header_line.index(DATE_COLUMN_HEADER_STRING),
            end: column_header_line.index(REMARKS_COLUMN_HEADER_STRING)
        }
        @remarks_column = {
            start: column_header_line.index(REMARKS_COLUMN_HEADER_STRING),
            end: column_header_line.index(CHEQUE_NUMBER_COLUMN_HEADER_STRING)
        }
        @cheque_column = {
            start: column_header_line.index(CHEQUE_NUMBER_COLUMN_HEADER_STRING),
            end: column_header_line.index(VAL_DATE_COLUMN_HEADER_STRING)
        }
        @val_date_column = {
            start: column_header_line.index(VAL_DATE_COLUMN_HEADER_STRING),
            end: column_header_line.index(VAL_DATE_COLUMN_HEADER_STRING) + LENGTH_OF_TRANSACTION_DATE_STRING
        }
        @debit_column = {
            start: @val_date_column[:start] + LENGTH_OF_TRANSACTION_DATE_STRING,
            end: column_header_line.index(DEBIT_COLUMN_HEADER_STRING) + 5
        }
        @credit_column = {
            start: @debit_column[:end] + 1,
            end: column_header_line.index(CREDIT_COLUMN_HEADER_STRING) + 7
        }
        @balance_column = {
            start: column_header_line.index(BALANCE_COLUMN_HEADER_STRING),
            end: -1
        }
        @columns = {
            date_column: @date_column,
            remarks_column: @remarks_column,
            cheque_column: @cheque_column,
            val_date_column: @val_date_column,
            debit_column: @debit_column,
            credit_column: @credit_column,
            balance_column: @balance_column
        }

      rescue NoMethodError
        return invalid_file
      end

    end

  end
end
