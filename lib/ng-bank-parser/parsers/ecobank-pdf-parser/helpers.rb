module NgBankParser
  module EcobankPdfHelpers

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
      details[:bank_name] = 'Ecobank'
      details[:account_number] = get_account_number(pdf_array)
      details[:account_name] =  get_account_name(pdf_array)

      transactions = get_transactions(pdf_array)
      details[:from_date] = transactions[0][:date]
      details[:to_date] = transactions[-1][:date]
      details[:transactions] = transactions

      return details
    end

    
    def has_valid_details?(pdf_array)
      return (get_account_number(pdf_array) and get_account_name(pdf_array))
    end


    def get_account_name(pdf_array)
      pdf_array.each do |row|
        row.each_with_index do |cell, index|
          if cell == 'Name'
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

    
    def get_transactions(pdf_array)
      start_index = get_first_line_of_transactions(pdf_array) 
      transactions = []

      opening_balance = pdf_array[start_index][-1]

      pdf_array[start_index..-1].each do |transaction|
        if valid_transaction?(transaction)

          transaction_hash = Hash.new
          transaction_hash[:date] = string_with_dash_to_date(transaction[0])
          
          if transaction.count == 6
            transaction_hash[:remarks] = transaction[2]
            transaction_hash[:ref] = transaction[3]
            transaction_hash[:amount] = amount_to_f(transaction[4])
            transaction_hash[:balance] = amount_to_f(transaction[5])
          elsif transaction.count == 5
            if transaction[2].chars.first === "'"
              transaction_hash[:remarks] = ""
              transaction_hash[:ref] = transaction[2]
              transaction_hash[:amount] = amount_to_f(transaction[3])
              transaction_hash[:balance] = amount_to_f(transaction[4])
            elsif transaction[2].split("'")[1]
              transaction_hash[:remarks] = transaction[2].split("'")[0]
              transaction_hash[:ref] = transaction[2].split("'")[1]
              transaction_hash[:amount] = amount_to_f(transaction[3])
              transaction_hash[:balance] = amount_to_f(transaction[4])
            else
              transaction_hash[:remarks] = transaction[2]
              transaction_hash[:ref] = transaction[3]
              amount_and_balance = transaction[4].split(" ")
              transaction_hash[:amount] = amount_to_f(amount_and_balance[0])
              transaction_hash[:balance] = amount_to_f(amount_and_balance[1])
            end
          else 
            remarks_and_ref = transaction[2].split("'")
            transaction_hash[:remarks] = remarks_and_ref[0]
            transaction_hash[:ref] = "'" << remarks_and_ref[1]
            amount_and_balance = transaction[3].split(" ")
            transaction_hash[:amount] = amount_to_f(amount_and_balance[0])
            transaction_hash[:balance] = amount_to_f(amount_and_balance[1])
          end

          transaction_hash[:type] = transaction_type(transaction_hash[:balance], opening_balance)
        
          opening_balance = transaction_hash[:balance]
          transactions << transaction_hash
        end
      end

      return transactions
    end


    def error(message)
      { status: 400, message: message }
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
        start = index + 1 if row[0] == 'Transaction Date'
      end

      return start
    end


    def valid_transaction?(line)
       # first column matches ecobank transaction date pattern and it has between 4 and 6 columns
      line[0] =~ /([0-3][0-9])[\-]([a-zA-Z]+)[\-]([0-9]{4})/ and line.count >= 4 and line.count <= 6
    end


    def string_with_dash_to_date(date_str)
      Date.strptime(date_str, '%d-%b-%y')
    end
  end
end