# Ng::Bank::Parser
This is a simple gem to parse Nigerian bank statements of all formats. If your bank and/or file format is not supported, consider reading the contribute wiki and submitting a pull request.

## API
Because not everyone develops in rails, we created a public API to use the gem at http://bank-parser.square-api.com/parse. The parameters are (bank_key, file_path, password). Read the *Usage* section for more information

    http://bank-parser.square-api.com/parse(bank_key, file_path, password)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ng-bank-parser'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ng-bank-parser

## Usage

Using the gem is pretty straightforward and simple.
```ruby
result = NgBankParser::Router.parse(bank_key, file_path, password)
```

`bank_key` is the key of the bank that provides the statement. There's a [list of supported banks and formats](#list-of-supported-banks) below, therefore use the key provided for each bank.

`file_path` is obviously where the file you're trying to parse exists.

`password` *(optional)* it's only required when the file you want to parse is password protected.

`result` is a hash that contains all the information you need from your statment.

```ruby
result = {
    status: 200,
    data: {
        bank_name: the_bank_name,
        account_number: the_account_number,
        account_name: the_account_name,
        from_date: first_transaction_date,
        to_date: last_transaction_date,
        transactions: an_array_of_transaction_hashes
    }
}
```

`:status` can either be 200 or 400. 200 for when the parsing is succesful and 200 for when it's not. A status of 400 is accompanied with an error message that aims to clarify why it could not parse the file.

```ruby
result = {
    status: 400,
    message: "RELEVANT ERROR MESSAGE"
}
```

Furthermore, `:transactions` in the `result` hash is an array of hashes. Below is an example of a transaction hash

```ruby
transaction = {
    date: transaction_date,
    amount: transaction_amount,
    type: debit_or_credit,
    balance: balance_after_transaction,
    remarks: remarks,
    ref: reference_id, # as provided by the statment
}

```

## List of Supported Banks

United Bank for Africa:
- key: uba
- supported formats: pdf

Guaranty Trust Bank:
- key: gtb
- supported formats: xls, xlsx

First Bank:
- key: firstbank
- supported formats: pdf

Heritage Bank:
- key: hb
- supported formats: pdf

Access Bank:
- key: accessbank
- supported formats: pdf

Ecobank:
- key: ecobank
- supported formats: pdf

## Contributing

Documentation on contribution can be found in the contribution wiki

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
