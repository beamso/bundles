require_relative 'spec_helper'
require_relative '../lib/bundle_calculator_impl'

RSpec.describe BundleCalculatorImpl do
  let(:json_filename) { File.join(File.dirname(__FILE__), 'fixtures', 'posts.json') }
  let(:order_array) { [%w[10 IMG], %w[15 FLAC]] }

  subject { described_class.new(json_filename, order_array) }

  describe '.initialize' do
    before do
      allow(Posts).to receive(:new).and_call_original
    end

    it 'called Posts as expected' do
      expect(Posts).to receive(:new).with(json_filename)
      subject
    end

    it 'has the expected number of order_items' do
      expect(subject.order_items.count).to eq(2)
    end
  end

  describe '.validate_order_items' do
    let(:instance) { described_class.new(json_filename, order_array) }

    subject { instance.validate_order_items }

    let(:order_array) { [%w[10 IMG], %w[0 FLAC], %w[1 FOO]] }

    before do
      allow(instance).to receive(:warn)
    end

    it 'warns about the invalid number' do
      expect(instance).to receive(:warn).with('Invalid number 0 for FLAC')
      subject
    end

    it 'warns about the invalid number' do
      expect(instance).to receive(:warn).with('Invalid format_code FOO')
      subject
    end

    it 'returns the valid items' do
      expect(subject.count).to eq(1)
    end
  end

  describe '.fulfil_order' do
    let(:order_array) { [%w[10 IMG], %w[15 FLAC], %w[13 VID]] }

    let(:instance) { described_class.new(json_filename, order_array) }

    subject { instance.fulfil_order }

    let(:fulfilled_order_item_printer) { instance_double(FulfilledOrderItemPrinter) }

    before do
      allow(FulfilledOrderItemPrinter).to receive(:new).and_return(fulfilled_order_item_printer)
      allow(fulfilled_order_item_printer).to receive(:print)
    end

    it 'calls the printer three times' do
      expect(fulfilled_order_item_printer).to receive(:print).exactly(3).times
      subject
    end
  end

  describe '.fulfil_order_items' do
    let(:order_array) { [%w[10 IMG], %w[15 FLAC], %w[13 VID]] }

    let(:instance) { described_class.new(json_filename, order_array) }

    subject { instance.fulfil_order_items }

    it 'should return 3 entries' do
      expect(subject.count).to eq(3)
    end

    it 'should return FulfilledOrderItems' do
      expect(subject).to all(be_a(FulfilledOrderItem))
    end

    context 'first item' do
      let(:item) { subject.first }

      it 'has the expected format_code' do
        expect(item.format_code).to eq('IMG')
      end

      it 'returns the expected count for bundle size of 10' do
        expect(item.count_for_bundle_size(10)).to eq(1)
      end

      it 'returns the expected count for bundle size of 5' do
        expect(item.count_for_bundle_size(5)).to eq(0)
      end

      it 'is complete' do
        expect(item.complete?).to eq(true)
      end
    end

    context 'second item' do
      let(:item) { subject[1] }

      it 'has the expected format_code' do
        expect(item.format_code).to eq('FLAC')
      end

      pending 'returns the expected count for bundle size of 9' do
        expect(item.count_for_bundle_size(9)).to eq(1)
      end

      pending 'returns the expected count for bundle size of 6' do
        expect(item.count_for_bundle_size(6)).to eq(1)
      end

      pending 'returns the expected count for bundle size of 3' do
        expect(item.count_for_bundle_size(3)).to eq(0)
      end

      it 'is complete' do
        expect(item.complete?).to eq(true)
      end
    end

    context 'third item' do
      let(:item) { subject.last }

      it 'has the expected format_code' do
        expect(item.format_code).to eq('VID')
      end

      it 'returns the expected count for bundle size of 9' do
        expect(item.count_for_bundle_size(9)).to eq(0)
      end

      it 'returns the expected count for bundle size of 5' do
        expect(item.count_for_bundle_size(5)).to eq(2)
      end

      it 'returns the expected count for bundle size of 3' do
        expect(item.count_for_bundle_size(3)).to eq(1)
      end

      it 'is complete' do
        expect(item.complete?).to eq(true)
      end
    end
  end

  describe '.fulfil_order_item' do
    let(:instance) { described_class.new(json_filename, order_array) }

    subject { instance.fulfil_order_item(order_item) }

    context 'cannot fulfil - too small' do
      before do
        allow(instance).to receive(:warn)
      end

      let(:order_item) { OrderItem.new(%w[4 IMG]) }

      it 'warns about it' do
        expect(instance).to receive(:warn).with('Cannot fulfil order of 4 IMG')
        subject
      end

      it 'is not complete' do
        expect(subject.complete?).to eq(false)
      end
    end

    context 'cannot fulfil - number does not align with any combination of bundles' do
      before do
        allow(instance).to receive(:warn)
      end

      let(:order_item) { OrderItem.new(%w[4 FLAC]) }

      it 'warns about it' do
        expect(instance).to receive(:warn).with('Cannot fulfil order of 4 FLAC')
        subject
      end

      it 'is not complete' do
        expect(subject.complete?).to eq(false)
      end
    end

    context 'matches one bundle' do
      let(:order_item) { OrderItem.new(%w[5 IMG]) }

      it 'returns the expected count for bundle size of 10' do
        expect(subject.count_for_bundle_size(10)).to eq(0)
      end

      it 'returns the expected count for bundle size of 5' do
        expect(subject.count_for_bundle_size(5)).to eq(1)
      end

      it 'is complete' do
        expect(subject.complete?).to eq(true)
      end
    end

    context 'matches other bundle' do
      let(:order_item) { OrderItem.new(%w[10 IMG]) }

      it 'returns the expected count for bundle size of 10' do
        expect(subject.count_for_bundle_size(10)).to eq(1)
      end

      it 'returns the expected count for bundle size of 5' do
        expect(subject.count_for_bundle_size(5)).to eq(0)
      end

      it 'is complete' do
        expect(subject.complete?).to eq(true)
      end
    end

    context 'matches both bundles' do
      let(:order_item) { OrderItem.new(%w[15 IMG]) }

      it 'returns the expected count for bundle size of 10' do
        expect(subject.count_for_bundle_size(10)).to eq(1)
      end

      it 'returns the expected count for bundle size of 5' do
        expect(subject.count_for_bundle_size(5)).to eq(1)
      end

      it 'is complete' do
        expect(subject.complete?).to eq(true)
      end
    end

    context 'matches larger bundle only' do
      let(:order_item) { OrderItem.new(%w[20 IMG]) }

      it 'returns the expected count for bundle size of 10' do
        expect(subject.count_for_bundle_size(10)).to eq(2)
      end

      it 'returns the expected count for bundle size of 5' do
        expect(subject.count_for_bundle_size(5)).to eq(0)
      end

      it 'is complete' do
        expect(subject.complete?).to eq(true)
      end
    end

    context 'another provided test case for flac' do
      let(:order_item) { OrderItem.new(%w[15 FLAC]) }

      pending 'returns the expected count for bundle size of 9' do
        expect(subject.count_for_bundle_size(9)).to eq(1)
      end

      pending 'returns the expected count for bundle size of 6' do
        expect(subject.count_for_bundle_size(6)).to eq(1)
      end

      pending 'returns the expected count for bundle size of 3' do
        expect(subject.count_for_bundle_size(3)).to eq(0)
      end

      it 'is complete' do
        expect(subject.complete?).to eq(true)
      end
    end

    context 'another provided test case for vid' do
      let(:order_item) { OrderItem.new(%w[13 VID]) }

      it 'returns the expected count for bundle size of 9' do
        expect(subject.count_for_bundle_size(9)).to eq(0)
      end

      it 'returns the expected count for bundle size of 5' do
        expect(subject.count_for_bundle_size(5)).to eq(2)
      end

      it 'returns the expected count for bundle size of 3' do
        expect(subject.count_for_bundle_size(3)).to eq(1)
      end

      it 'is complete' do
        expect(subject.complete?).to eq(true)
      end
    end

    # context 'a slightly large order' do
    #   let(:order_item) { OrderItem.new(%w[500 IMG]) }

    #   it 'returns the expected count for bundle size of 10' do
    #     expect(subject.count_for_bundle_size(10)).to eq(50)
    #   end

    #   it 'returns the expected count for bundle size of 5' do
    #     expect(subject.count_for_bundle_size(5)).to eq(0)
    #   end

    #   it 'is complete' do
    #     expect(subject.complete?).to eq(true)
    #   end
    # end
  end
end
