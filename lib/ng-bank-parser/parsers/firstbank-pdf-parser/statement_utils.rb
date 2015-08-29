module NgBankParser
  module StatementUtils

    def get_first_page_text reader
      lines = reader.pages.first.text.remove_empty_lines.lines #lines without the spaces
      lines.map{ |line| split_on_2_or_more_spaces(line) }
    end


    def get_all_text reader
      all_lines = []
      reader.pages.each do |page|
        lines_of_page = page.text.remove_empty_lines.lines
        all_lines += lines_of_page
      end
      all_lines
    end


    def get_page_text page_text
      page_text.text.remove_empty_lines.lines
    end


    def get_pages reader
      reader.pages
    end


    def get_transaction_table_index lines
      lines_in_file = lines.map{ |line| split_on_2_or_more_spaces(line) }
      lines_in_file.each_with_index do |line, index|
        if line[0] == 'TransDate'
            return index + 1
        end
      end
      return -1 #no transactions found on page
    end


    private

    def split_on_2_or_more_spaces str
      str.strip.split(/\s\s+/)
    end

    def remove_empty_lines
      self.gsub /^$\n/, ''
    end
  end
end
