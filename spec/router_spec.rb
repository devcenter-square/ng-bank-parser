require 'spec_helper'

describe "Router" do
	before :all do
		$Banks.each.with_index do |bank, index|
			@bank_name = bank[:key]
			@value =  bank[:key] = index

			bank[:parsers].each do |parser|
				@format = parser[:format]
				@extension = parser[:extensions].reduce(:concat)
				@extension_array = parser[:extensions]
				@valid = parser[:valid]
			end
		end
	end

	context "router" do
		it "checks if index value is not nil" do					
			expect(@value).not_to equal(nil)
		end

		it "adds extension to array using index value" do			
			@extension_array += $Banks[@value][:parsers].map {|e| e[:extensions]}

			expect(@extension_array).not_to match_array([])
		end		
	end

	context "parser_picker" do
		it "checks file extension in array" do
			filename = @bank_name + "-" + @format + "-valid" + ".#{@extension}"
			extension_name = File.extname(filename).delete(".")

			expect(@extension_array).to include(extension_name)
		end
	end

	context "ng_bank_parsers" do
		it "builds parser that exists and works for file" do
			class_name = @bank_name.capitalize + @format.capitalize
			class_object = NgBankParser.const_get(class_name)
			response = class_object.parse(@valid)

			expect(response[:status]).to eq(1);
		end
	end
end
