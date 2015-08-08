require_relative 'constants'

module NgBankParser
  module PdfChecks
    include Constants

    private

    def is_valid_pdf?
     is_first_line_of_first_page_correct? && is_date_range_line_correct? && is_account_number_line_correct? && are_columns_correct?
    end


    def is_first_line_of_first_page_correct?
      line_string = @first_page_text.lines[0].remove_white_spaces.downcase!
      return line_string.end_with?(FIRST_LINE_CHECKER_STRING)
    end

    def is_date_range_line_correct?
      date_line = @first_page_text.lines[1]
      date_line_string = date_line.remove_white_spaces.downcase!
      return date_line_string.get_text_between_markers(START_DATE_STRING, END_DATE_STRING).upcase!.is_date? && date_line_string.get_text_after_marker(START_DATE_STRING).upcase!.is_date?
    end

    def is_account_number_line_correct?
      account_number_line = @first_page_text.lines[ACCOUNT_NUMBER_LINE_INDEX]
      return account_number_line.remove_white_spaces.downcase!.start_with?(ACCOUNT_NUMBER_STRING)
    end

    def are_columns_correct?
      is_date_column_correct? && is_remarks_column_correct? && is_debit_column_correct? && is_credit_column_correct? && is_balance_column_correct?
    end

    def is_date_column_correct?
      @first_page_text.lines[TABLE_HEADER_LINE_INDEX]
          .extract_column(@date_column)
          .remove_white_spaces.downcase![COLUMN_OFFSET_RANGE] == DATE_COLUMN_HEADER_STRING
    end

    def is_remarks_column_correct?
      @first_page_text.lines[TABLE_HEADER_LINE_INDEX].extract_column(@remarks_column).remove_white_spaces.downcase![COLUMN_OFFSET_RANGE] == REMARKS_COLUMN_HEADER_STRING
    end

    def is_debit_column_correct?
      @first_page_text.lines[TABLE_HEADER_LINE_INDEX].extract_column(@debit_column).remove_white_spaces.downcase! == DEBIT_COLUMN_HEADER_STRING
    end

    def is_credit_column_correct?
      @first_page_text.lines[TABLE_HEADER_LINE_INDEX].extract_column(@credit_column).remove_white_spaces.downcase! == CREDIT_COLUMN_HEADER_STRING
    end

    def is_balance_column_correct?
      @first_page_text.lines[TABLE_HEADER_LINE_INDEX].extract_column(@balance_column).remove_white_spaces.downcase! == BALANCE_COLUMN_HEADER_STRING
    end


  end
end
