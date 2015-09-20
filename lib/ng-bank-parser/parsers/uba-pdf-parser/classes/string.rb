class String
  def extract_column(column)
    self[column[:start]..column[:end]]
  end

  def remove_empty_lines
    self.gsub /^$\n/, ''
  end

  def remove_multiple_lines
    self.gsub('\n', '')
  end

  def remove_white_spaces
    self.gsub(/\s+/, "")
  end

  def reduce_to_singular_white_space
    self.gsub(/\s+/, " ")
  end

  def remove_commas
    return self.gsub(/,/, '')
  end


  def get_text_between_markers(marker1, marker2)
    self[/#{Regexp.escape(marker1)}(.*?)#{Regexp.escape(marker2)}/m, 1]
  end

  def get_text_after_marker(marker)
    self.partition(marker).last
  end

  def get_date_string
    self[0...10]
  end

  def get_first_line
    self.lines[0]
  end

  def is_date?
    begin
      Date.parse(self)
    rescue ArgumentError
      return false
    end
    return true
  end

  def convert_to_date
    Date.strptime(self, '%d-%b-%Y')
  end

  def get_numbers
    self.remove_commas.to_f
  end

end
