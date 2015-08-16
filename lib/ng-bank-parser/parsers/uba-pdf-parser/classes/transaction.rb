require 'active_support/json/decoding.rb'
require 'active_support/json/encoding.rb'


class Transaction

  TYPE = {
      debit: 'debit',
      credit: 'credit'
  }


  def initialize(string, columns)
    set_date_from_transaction_string(string)
    set_amount_and_type_from_transaction_string(string, columns[:debit_column], columns[:credit_column])
    set_balance_from_transaction_string(string, columns[:balance_column])
    set_remarks_from_transaction_string(string, columns[:remarks_column])
    set_ref
  end

  def to_hash
    {
        date: @date,
        amount: @amount,
        type: @type,
        balance: @balance,
        remarks: @remarks,
        ref: @ref
    }
  end

  private

  def set_date_from_transaction_string(string)
    @date = Date.strptime(string.get_first_line.get_date_string, '%d-%m-%Y')
  end

  def set_amount_and_type_from_transaction_string(string, debit_column, credit_column)
    debit = string.get_first_line.extract_column(debit_column).remove_white_spaces
    credit = string.get_first_line.extract_column(credit_column).remove_white_spaces

    if (debit.blank? && !credit.blank?)
      @type = TYPE[:credit]
      @amount = credit.remove_commas.to_f
    elsif (credit.blank? && !debit.blank?)
      @type = TYPE[:debit]
      @amount = debit.remove_commas.to_f
    end
  end

  def set_balance_from_transaction_string(string, balance_column)
    @balance = string.get_first_line.extract_column(balance_column).remove_white_spaces.remove_commas.to_f
  end

  def set_remarks_from_transaction_string(string, remarks_column)
    @remarks ||= ''
    if string.lines.count == 1
      @remarks = string.extract_column(remarks_column)
    elsif string.lines.count > 1
      string.lines.each do |line|
        @remarks = @remarks.+ line.extract_column(remarks_column)
      end
    end
    @remarks = @remarks.reduce_to_singular_white_space
  end

  def set_ref
    @ref = '0'
  end


end

