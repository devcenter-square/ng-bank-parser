module NgBankParser
	class Banks
    BANK_DEFINITIONS = {
        gtb: {
            name: 'Guaranty Trust Bank',
            parsers: {xls: 'excel', xlsx: 'excel'}
        },
        uba:  {
            name: 'United Bank for Africa',
            parsers: {pdf: 'pdf'}
        },
        firstbank: {
            name: 'First Bank',
            parsers: {pdf: 'pdf'}
        }
    }
	end
end