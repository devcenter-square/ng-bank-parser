require 'spec_helper'

describe "Router" do

	context "variables exist" do
		it "checks if bank name is not empty" do
			expect(:bank_key).not_to equal(nil), "bank name should not be empty"
		end

		it "checks if file path is not empty" do
			expect(:path).not_to equal(nil), "file path should not be empty"
		end
	end

	context "when tested" do
		it "calls correct parser" do
			@banks = NgBankParser::Banks::BANK_DEFINITIONS;

			# Choose a random bank and parser
			random_bank = @banks.sample
			random_parser = random_bank[:parsers].sample

			bank_key = random_bank[:key]
			path = random_parser[:valid]
			password = random_parser[:fixture_password]

			# Get response from router
			router_response = NgBankParser::Router.parse(bank_key, path, password);

			# Get expected response
			class_name = bank_key.capitalize + random_parser[:format].capitalize;
			class_object = NgBankParser.const_get(class_name)
			parser_response = class_object.parse(path, password)

			expect(router_response).to eq(parser_response)
		end
	end
end
