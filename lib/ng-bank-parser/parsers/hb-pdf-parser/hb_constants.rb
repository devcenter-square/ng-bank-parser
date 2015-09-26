module NgBankParser
  module HbConstants
    ACCEPTED_FORMATS = ['.pdf']

    INVALID_ACCOUNT_STATUS = 400
    VALID_ACCOUNT_STATUS = 200

    SECOND_PAGE_INDEX = 1
    DURATION_DATE_LINE_INDEX = 3
    ACCOUNT_NAME_LINE_INDEX = 5
    ACCOUNT_NUMBER_LINE_INDEX = 6
    TRANSACTION_HEADER_INDEX = 11
    TRANSACTION_DATE_INDEX = 0
    TRANSACTION_DEBIT_INDEX = -3
    TRANSACTION_CREDIT_INDEX = -2
    TRANSACTION_BALANCE = 131
    TRANSACTION_BALANCE_END = 155
    TRANSACTION_REMARKS = 32
    TRANSACTION_REMARKS_END = 92
    TRANSACTION_REFERENCE = 20
    TRANSACTION_REFERENCE_END = 30
    TRANSACTION_DEBIT =  92
    TRANSACTION_DEBIT_END = 105
    TRANSACTION_CREDIT = 110
    TRANSACTION_CREDIT_END = 130


    ACCOUNT_NAME_FIRST_MAKER = 'name'
    ACCOUNT_NAME_SECOND_MAKER = 'debit turnover'
    ACCOUNT_NUMBER_MAKER = 'account number'
    END_DATE_MAKER = '-'

    INVALID_FILE_FORMAT_STRING = 'File Format Not Valid'
    INVALID_ACCOUNT_STATEMENT = 'File Is Not A Valid Heritage Bank Account Statement'

    CORRECT_RC_NUMBER = 'RC No 9868'

    COLUMN_ARRANGEMENT = 'valuedatereferencenarrationdebitcreditbalance'




  end
end