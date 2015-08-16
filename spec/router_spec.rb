require 'spec_helper'

describe "Router" do

	context "router variables exist" do
		it "checks if bank name is not empty" do
			expect(:bank_name).not_to equal(nil), "bank name should not be empty"
		end

		it "checks if file path is not empty" do
			expect(:path).not_to equal(nil), "file path should not be empty"
		end
	end

	context "has file extension" do
	    key = $Banks.map { |e| e[:key].capitalize }
      	format = $Banks.map { |e| e[:parsers].map { |e| e[:format].capitalize }}
      	class_name = key + format.reduce(:concat)
      	array = []

		it "is supported" do
			class_object = NgBankParser.const_get(class_name.reduce(:concat))			
			response = class_object.parse(:path.to_s)

			expect(response[:status]).to eq(0);
		end

		it "is not supported" do
			extension_name = File.extname(:path.to_s)

			expect(array).not_to include(extension_name) 
		end
	end

end
