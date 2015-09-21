require_relative 'hb_constants'

module NgBankParser
  module HbTransactionHelpers
    include HbConstants
    def pdf_is_valid?(file)
      has_transaction_page? && has_transaction_columns? && has_correct_rc_number? && !has_encryption?(file)
    end

    private

    def has_transaction_page?
      @reader.pages[SECOND_PAGE_INDEX].present?
    end

    def has_correct_rc_number?
      @reader.pages.first.text.remove_empty_lines.lines.first.strip == CORRECT_RC_NUMBER
    end

    def has_transaction_columns?
      @reader.pages[SECOND_PAGE_INDEX].text.remove_empty_lines.lines[TRANSACTION_HEADER_INDEX].remove_white_spaces == COLUMN_ARRANGEMENT
    end

    def has_encryption?(file)
      begin
        @reader = PDF::Reader.new(file)
        false
      rescue PDF::Reader::EncryptedPDFError
        true
      end
    end

    def set_account_name
      @account_name = @reader.pages[SECOND_PAGE_INDEX].text.remove_empty_lines.lines[ACCOUNT_NAME_LINE_INDEX].get_text_between_markers(ACCOUNT_NAME_FIRST_MAKER, ACCOUNT_NAME_SECOND_MAKER).remove_white_spaces
    end

    def set_account_number
      @account_number = @reader.pages[SECOND_PAGE_INDEX].text.remove_empty_lines.lines[ACCOUNT_NUMBER_LINE_INDEX].strip.get_text_after_marker(ACCOUNT_NUMBER_MAKER).remove_white_spaces
    end

    def set_end_date
      @end_date = Date.parse(@reader.pages[SECOND_PAGE_INDEX].text.remove_empty_lines.lines[DURATION_DATE_LINE_INDEX].get_text_after_marker(END_DATE_MAKER).remove_white_spaces)
    end

    def set_start_date
      @start_date = Date.parse(@reader.pages[SECOND_PAGE_INDEX].text.remove_empty_lines.lines[DURATION_DATE_LINE_INDEX].get_text_between_markers(' ', END_DATE_MAKER).remove_white_spaces)
    end

    def set_transaction_attr(line)
      transaction_object = {}
      transaction_object[:date] = transaction_date(line)

      transaction_object[:balance] = transaction_balance(line)
      transaction_object[:remarks] = transaction_remarks(line)
      transaction_object[:ref] = transaction_reference(line)
      transaction_object
    end

    def transaction_is_a_debit?(transaction_items_list, line)
      transaction_items_list[TRANSACTION_DEBIT_INDEX] && debit_amount(line) > 0.00
    end

    def transaction_is_a_credit?(transaction_items_list, line)
      transaction_items_list[TRANSACTION_CREDIT_INDEX] && credit_amount(line) > 0.00
    end

    def create_transaction(line, type)
      transaction = set_transaction_attr(line)
      set_transaction_type(transaction, type, line)
      @transactions << transaction
    end

    def set_transaction_type(transaction, type, line)
      if type == 'debit'
        transaction[:amount] = debit_amount(line)
        transaction[:type] = type
      elsif type == 'credit'
        transaction[:amount] = credit_amount(line)
        transaction[:type] = type
      end
    end

    def transaction_date(line)
      Date.parse(line[0..19].remove_white_spaces)
    end

    def transaction_balance(line)
      line[TRANSACTION_BALANCE..TRANSACTION_BALANCE_END].get_numbers
    end

    def transaction_remarks(line)
      line[TRANSACTION_REMARKS..TRANSACTION_REMARKS_END].remove_white_spaces
    end

    def transaction_reference(line)
      line[TRANSACTION_REFERENCE..TRANSACTION_REFERENCE_END].remove_white_spaces
    end

    def debit_amount(line)
      line[TRANSACTION_DEBIT..TRANSACTION_DEBIT_END].get_numbers
    end

    def credit_amount(line)
      line[TRANSACTION_CREDIT..TRANSACTION_CREDIT_END].get_numbers
    end


    def transaction_items(line)
      line.strip.split("   ").reject(&:empty?)
    end
  end
end
