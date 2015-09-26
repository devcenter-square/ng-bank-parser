require 'spec_helper'

describe "Banks" do
	subject { NgBankParser::Banks::BANK_DEFINITIONS }

	it { is_expected.to be_a_kind_of(Array) }
	it { is_expected.not_to be_empty }
end


describe "Every Bank" do
	subject { NgBankParser::Banks::BANK_DEFINITIONS }

	it "is unique" do
		expect(subject.length).to equal(subject.uniq.length)
	end
	it "has valid keys" do
		subject.each do |bank|
			expect(bank).to match({
				:key => an_instance_of(String),
				:name => an_instance_of(String),
				:parsers => an_instance_of(Array)
        	})
		end
	end

	it "has valid parser keys" do
		subject.each do |bank|
			bank[:parsers].each do |parser|
				expect(parser).to include({
					:format => an_instance_of(String),
					:valid => an_instance_of(String),
					:invalid => an_instance_of(String),
					:extensions => an_instance_of(Array)
	        	})
			end
		end
	end
end

NgBankParser::Banks::BANK_DEFINITIONS.each do |bank|
	key = bank[:key].capitalize

	bank[:parsers].each do |parser|
		describe key + " " + parser[:format] + " " +  "parser" do
			class_name = key.capitalize + parser[:format].capitalize;
			class_object = NgBankParser.const_get(class_name)
			valid_file_path = parser[:valid]
			invalid_file_path = parser[:invalid]

			context "has required files" do
				it "has parser file" do
					filename = bank[:key] + "-" + parser[:format] + "-parser.rb"
					path = "lib/ng-bank-parser/parsers/" + filename
					
					expect(File).to exist(path), "Didnt find #{filename} in the parsers folder"
				end
				it "has test files" do			
					expect(File).to exist(valid_file_path), "Valid file path is wrong. Please check"
					expect(File).to exist(invalid_file_path), "Invalid file path is wrong. Please check"
				end
			end

			context "with invalid statement" do
				response = class_object.parse(invalid_file_path)

				it "returns proper response" do
					expect(response[:status]).to eq(400);
				end
			end

			context "with valid statement" do
				password = parser[:fixture_password]
				response = class_object.parse(valid_file_path, password)

				it "parses statement correctly" do
					expect(response[:status]).to eq(200)
					expect(response[:data]).to match({
						:bank_name => an_instance_of(String),
						:account_number => an_instance_of(String),
						:account_name => an_instance_of(String),
						:from_date => an_instance_of(Date),
						:to_date => an_instance_of(Date),
						:transactions => an_instance_of(Array)
		        	})
				end

				it "returns valid transactions" do
		        	response[:data][:transactions].each do |row|
		        		expect(row).to match({
							:date => an_instance_of(Date),
							:ref => an_instance_of(String),
							:type => a_string_matching(/^(credit|debit)$/),
							:amount => an_instance_of(Float),
							:balance => an_instance_of(Float),
							:remarks => an_instance_of(String)
			        	})
		        	end
				end
			end
		end
	end
end