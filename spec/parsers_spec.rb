require 'spec_helper'

describe "Parsers" do
	subject { $Parsers }

	it { is_expected.to be_a_kind_of(Array) }
	it { is_expected.not_to be_empty }


	describe "Every Parser" do
		it "is unique" do
			expect(subject.length).to equal(subject.uniq.length)
		end
		it "has valid keys" do
			subject.each do |parser|
				expect(parser).to be_a_kind_of(Hash)
				expect(parser.keys).to contain_exactly(:key, :name, :format, :valid, :invalid, :empty)
			end
		end
		it "has parser file" do
			subject.each do |parser|
				filename = parser[:key] + "-" + parser[:format] + "-parser.rb"
				path = "lib/ng-bank-parser/parsers/" + filename
				
				expect(File).to exist(path), "Didnt find #{filename} in the parsers folder"
				expect(File).to exist(path), "Didnt find #{filename} in the parsers folder"
			end
		end
	end
end