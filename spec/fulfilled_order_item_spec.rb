require_relative 'spec_helper'
require_relative '../lib/fulfilled_order_item'
require_relative '../lib/post'
require_relative '../lib/posts'

RSpec.describe FulfilledOrderItem do
  let(:post) { instance_double(Post) }
  let(:total) { 3 }

  subject { described_class.new(post, total) }

  describe '.post' do
    it 'has the expected post' do
      expect(subject.post).to eq(post)
    end
  end

  describe '.total' do
    it 'has the expected total' do
      expect(subject.total).to eq(3)
    end
  end

  describe '.format_code' do
    before do
      allow(post).to receive(:format_code).and_return('FOO')
    end

    it 'has the expected format_code' do
      expect(subject.format_code).to eq('FOO')
    end
  end

  describe 'count_for_bundle_size' do
    let(:instance) { described_class.new(post, total) }

    it 'has the expected count_for_bundle_size' do
      expect(instance.count_for_bundle_size(3)).to eq(0)
    end
  end

  describe '.set_bundle_size_count' do
    let(:instance) { described_class.new(post, total) }

    subject { instance.set_bundle_size_count(3, 2) }

    it 'has the expected count_for_bundle_size' do
      subject
      expect(instance.count_for_bundle_size(3)).to eq(2)
    end
  end

  describe '.increment_bundle_size' do
    let(:instance) { described_class.new(post, total) }

    subject { instance.increment_bundle_size(3) }

    it 'has the expected count_for_bundle_size' do
      subject
      expect(instance.count_for_bundle_size(3)).to eq(1)
    end
  end

  describe '.complete?' do
    let(:instance) { described_class.new(post, 15) }

    subject { instance.complete? }

    context 'no bundles added' do
      it 'is false' do
        expect(subject).to eq(false)
      end
    end

    context 'sum of bundle_size multiplied by count is equal to the total' do
      before do
        instance.increment_bundle_size(6)
        instance.increment_bundle_size(6)
        instance.increment_bundle_size(3)
      end

      it 'is true' do
        expect(subject).to eq(true)
      end
    end

    context 'sum of bundle_size multiplied by count is not equal to the total' do
      before do
        instance.increment_bundle_size(6)
        instance.increment_bundle_size(3)
      end

      it 'is false' do
        expect(subject).to eq(false)
      end
    end
  end

  describe '.number_of_bundles' do
    let(:instance) { described_class.new(post, 15) }

    subject { instance.number_of_bundles }

    context 'no bundles added' do
      it 'is zero' do
        expect(subject).to eq(0)
      end
    end

    context 'with bundles added' do
      before do
        instance.increment_bundle_size(6)
        instance.increment_bundle_size(6)
        instance.increment_bundle_size(3)
        instance.increment_bundle_size(3)
      end

      it 'is the number of bundles added' do
        expect(subject).to eq(4)
      end
    end
  end

  describe '.dup' do
    let(:instance) { described_class.new(post, 15) }

    subject { instance.dup }

    context 'with bundles added' do
      before do
        instance.increment_bundle_size(6)
        instance.increment_bundle_size(6)
        instance.increment_bundle_size(3)
        instance.increment_bundle_size(3)
      end

      it 'has the expected post' do
        expect(subject.post).to eq(post)
      end

      it 'has the expected total' do
        expect(subject.total).to eq(15)
      end

      it 'has the expected bundle count for a bundle size of 6' do
        expect(subject.count_for_bundle_size(6)).to eq(2)
      end

      it 'has the expected bundle count for a bundle size of 3' do
        expect(subject.count_for_bundle_size(3)).to eq(2)
      end

      it 'does not copy the hash across' do
        result = subject
        instance.increment_bundle_size(3)
        expect(result.count_for_bundle_size(3)).to eq(2)
      end
    end
  end

  describe '.total_cost' do
    let(:json_filename) { File.join(File.dirname(__FILE__), 'fixtures', 'posts.json') }
    let(:posts) { Posts.new(json_filename) }
    let(:post) { posts.post_by_format_code('FLAC') }
    let(:instance) { FulfilledOrderItem.new(post, 15) }

    before do
      instance.increment_bundle_size(9)
      instance.increment_bundle_size(6)
    end

    subject { instance.total_cost }

    it 'returns the expected total cost' do
      expect(subject).to eq(1957.5)
    end
  end

  describe '.cost_for_bundle_size' do
    let(:json_filename) { File.join(File.dirname(__FILE__), 'fixtures', 'posts.json') }
    let(:posts) { Posts.new(json_filename) }
    let(:post) { posts.post_by_format_code('FLAC') }
    let(:instance) { FulfilledOrderItem.new(post, 18) }

    let(:bundle_size) { 9 }

    subject { instance.cost_for_bundle_size(bundle_size) }

    before do
      instance.increment_bundle_size(9)
      instance.increment_bundle_size(9)
    end

    it 'returns the cost for the bundle multiplied by the number of times it was used' do
      expect(subject).to eq(2295)
    end
  end
end
