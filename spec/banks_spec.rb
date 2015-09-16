require 'spec_helper'

describe 'Banks' do
	subject { NgBankParser::Banks::BANK_DEFINITIONS }

	it { is_expected.to be_a_kind_of(Hash) }
	it { is_expected.not_to be_empty }
end


describe 'Every Bank' do
  subject { NgBankParser::Banks::BANK_DEFINITIONS }

	it 'contains 4 banks' do
		expect(subject.length).to equal(3)
  end

  context 'first bank' do
    it 'has the right key' do
      expect(subject[:firstbank]).to_not be_nil
    end

    it 'has the right name' do
      expect(subject[:firstbank][:name]).to eq('First Bank')
    end

    it 'has pdf parser' do
      expect(subject[:firstbank][:parsers][:pdf]).to eq('pdf')
    end
  end

  context 'Guaranty Trust Bank' do
    it 'has the right key' do
      expect(subject[:gtb]).to_not be_nil
    end

    it 'has the right name' do
      expect(subject[:gtb][:name]).to eq('Guaranty Trust Bank')
    end

    it 'has xls and xlsx parser' do
      expect(subject[:gtb][:parsers]).to eq({xls: 'excel', xlsx: 'excel'})
    end
  end

  context 'United Bank for Africa' do
    it 'has the right key' do
      expect(subject[:uba]).to_not be_nil
    end

    it 'has the right name' do
      expect(subject[:uba][:name]).to eq('United Bank for Africa')
    end

    it 'supports pdf parser' do
      expect(subject[:uba][:parsers][:pdf]).to eq('pdf')
    end
  end
end
#
# it "parses statement correctly" do
#   expect(response[:status]).to eq(1)
#   expect(response[:data]).to match({
#                                        :bank_name => an_instance_of(String),
#                                        :account_number => an_instance_of(String),
#                                        :account_name => an_instance_of(String),
#                                        :from_date => an_instance_of(Date),
#                                        :to_date => an_instance_of(Date),
#                                        :transactions => an_instance_of(Array)
#                                    })
# end
#
# it "returns valid transactions" do
#   response[:data][:transactions].each do |row|
#     expect(row).to match({
#                              :date => an_instance_of(Date),
#                              :ref => an_instance_of(String),
#                              :type => a_string_matching(/^(credit|debit)$/),
#                              :amount => an_instance_of(Float),
#                              :balance => an_instance_of(Float),
#                              :remarks => an_instance_of(String)
#                          })
#   end
# end