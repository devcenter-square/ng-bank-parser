module AccessbankPdfHelpers

  def pdf_to_a(pdf)
    lines = []

    pdf.pages.each do |page|
      remove_line_spacing(page.text).each do |line|
        lines << line.strip.split(/\s\s+/)
      end
    end

    return lines
  end


  def get_details(pdf_array)

    details = Hash.new

    details[:bank_name] = 'Access Bank'
    details[:account_number] = get_account_number(pdf_array)
    details[:account_name] =  get_account_name(pdf_array)

    date_range = get_date_range(pdf_array)

    details[:from_date] = string_with_slash_to_date(date_range[:from])
    details[:to_date] = string_with_slash_to_date(date_range[:to])
    details[:transactions] = get_transactions(pdf_array)

    return details
  end


  def has_valid_details?(pdf_array)
    return (get_account_number(pdf_array) and get_account_name(pdf_array) and get_date_range(pdf_array))
  end


  def get_account_name(pdf_array)

    pdf_array.each do |row|
      row.each_with_index do |cell, index|
        if cell == 'Account Name'
          return row[index + 1]
        end
      end
    end

    return nil
  end


  def get_account_number(pdf_array)

    pdf_array.each do |row|
      row.each do |cell|
        if cell =~ /[0-9]{10}/
          return cell
        end
      end
    end

    return nil
  end


  def get_date_range(pdf_array)
    pdf_array.each_with_index do |row, index|
      if row.count == 1
        if row.first =~ /([0-3][0-9])[\/]([0-1][0-9])[\/]([0-9]{4})/ and pdf_array[index + 1].first =~ /([0-3][0-9])[\/]([0-1][0-9])[\/]([0-9]{4})/
          return { from: row.first, to: pdf_array[index + 1].first }
        end
      end
    end

    return nil
  end


  def get_transactions(pdf_array)
    start_index = get_first_line_of_transactions(pdf_array)
    transactions = []

    opening_balance = pdf_array[1][1]

    pdf_array[start_index..-1].each do |transaction|
      if valid_transaction?(transaction)

        transaction_hash= Hash.new
        transaction_hash[:date] = string_with_dash_to_date(transaction[0])
        transaction_hash[:remarks] = transaction[2]

        if transaction.count == 6 # ref code present
          transaction_hash[:ref] = transaction[3]
          transaction_hash[:amount] = amount_to_f(transaction[4])
          transaction_hash[:balance] = amount_to_f(transaction[5])
          transaction_hash[:type] = transaction_type(transaction_hash[:balance], opening_balance)
        else #no ref code
          transaction_hash[:ref] = ''
          transaction_hash[:amount] = amount_to_f(transaction[3])
          transaction_hash[:balance] = amount_to_f(transaction[4])
          transaction_hash[:type] = transaction_type(transaction_hash[:balance], opening_balance)
        end

        opening_balance = transaction_hash[:balance]
        transactions << transaction_hash
      end
    end

    return transactions
  end


  def error(msg)
    { status: 400, message: msg }
  end

  def success(data)
    { status: 200, data: data }
  end


  private
    def remove_line_spacing(str)
      str.gsub(/^$\n/, '').lines
    end


    def transaction_type(current_balance, former_balance)
      former_balance = amount_to_f(former_balance) if former_balance.is_a?(String)

      current_balance - former_balance > 1 ? 'credit' : 'debit'
    end


    def amount_to_f(amount)
      amount.gsub(/[^\d\.]/, '').to_f
    end


    def get_first_line_of_transactions(pdf_array)
      start = -1

      pdf_array.each_with_index do |row, index|
         start = index + 1 if row[0] == 'Date'
      end

      return start
    end


    def valid_transaction?(line)
      line[0] =~ /([0-3][0-9])[\-]([a-zA-Z]+)[\-](1[0-9])/ #first column matches access bank transaction date pattern
    end


    def string_with_dash_to_date(date_str)
      Date.strptime(date_str, '%d-%b-%y')
    end

    
    def string_with_slash_to_date(date_str)
      Date.strptime(date_str, '%d/%m/%Y')
    end
end