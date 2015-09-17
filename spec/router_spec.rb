require 'spec_helper'

describe 'Router' do

	context 'variables exist' do
		it 'checks if bank name is not empty' do
			expect(:bank_key).not_to equal(nil), 'bank name should not be empty'
		end

		it 'checks if file path is not empty' do
			expect(:path).not_to equal(nil), 'file path should not be empty'
		end
  end

  context 'with invalid file type' do
    context 'when statement is of type pdf from uba' do
      it 'parses file' do
        parse = NgBankParser::Router.parse('uba', 'lib/ng-bank-parser/fixtures/uba-pdf-invalid.pdf')
        expect(parse[:status]).to eq 400
      end

      it 'calls the right class' do
        expect(NgBankParser::UbaPdf).to receive(:parse)
        NgBankParser::Router.parse('uba', 'lib/ng-bank-parser/fixtures/uba-pdf-invalid.pdf')
      end
    end

    context 'when statement is of type excel from gtb' do
      it 'parses file' do
        parse = NgBankParser::Router.parse('gtb', 'lib/ng-bank-parser/fixtures/gtb-excel-invalid.pdf')
        expect(parse[:status]).to eq 400
      end

      it 'calls the right class' do
        expect(NgBankParser::GtbExcel).to_not receive(:parse)
        NgBankParser::Router.parse('gtb', 'lib/ng-bank-parser/fixtures/gtb-excel-invalid.pdf')
      end
    end

    context 'when statement is of type pdf from firstbank' do
      it 'parses file' do
        parse = NgBankParser::Router.parse('firstbank', 'lib/ng-bank-parser/fixtures/firstbank-pdf-invalid.pdf', 19856)
        expect(parse[:status]).to eq 400
      end

      it 'calls the right class' do
        expect(NgBankParser::FirstbankPdf).to receive(:parse)
        NgBankParser::Router.parse('firstbank', 'lib/ng-bank-parser/fixtures/firstbank-pdf-invalid.pdf', 19856)
      end
    end
  end

  context 'with valid file type' do
    context 'when statement is of type pdf from uba' do
      it 'parses file' do
        parse = NgBankParser::Router.parse('uba', 'lib/ng-bank-parser/fixtures/uba-pdf-valid.pdf')
        expect(parse[:status]).to eq 200
      end

      it 'calls the right class' do
        expect(NgBankParser::UbaPdf).to receive(:parse)
        NgBankParser::Router.parse('uba', 'lib/ng-bank-parser/fixtures/uba-pdf-valid.pdf')
      end
    end

    context 'when statement is of type excel from gtb' do
      it 'parses file' do
        parse = NgBankParser::Router.parse('gtb', 'lib/ng-bank-parser/fixtures/gtb-excel-valid.xlsx')
        expect(parse[:status]).to eq 200
      end

      it 'calls the right class' do
        expect(NgBankParser::GtbExcel).to receive(:parse)
        NgBankParser::Router.parse('gtb', 'lib/ng-bank-parser/fixtures/gtb-excel-valid.xlsx')
      end
    end

    context 'when statement is of type pdf from firstbank' do
      it 'parses file' do
        parse = NgBankParser::Router.parse('firstbank', 'lib/ng-bank-parser/fixtures/firstbank-pdf-valid.pdf', 19856)
        expect(parse[:status]).to eq 200
      end

      it 'calls the right class' do
        expect(NgBankParser::FirstbankPdf).to receive(:parse)
        NgBankParser::Router.parse('firstbank', 'lib/ng-bank-parser/fixtures/firstbank-pdf-valid.pdf', 19856)
      end
    end
  end

  context 'when bank is not supported' do
    it 'returns error message' do
      expect(NgBankParser::Router).to_not receive(:parse_with)
      parse = NgBankParser::Router.parse('bank_not_supported', 'lib/ng-bank-parser/fixtures/firstbank-pdf-valid.pdf', 19856)

      expect(parse[:message]).to eq 'Your bank is not yet supported'
    end
  end
end
