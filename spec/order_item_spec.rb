require_relative 'spec_helper'
require_relative '../lib/order_item'
require_relative '../lib/post'
require_relative '../lib/posts'

RSpec.describe OrderItem do
  let(:array) { %w[10 IMG] }

  subject { described_class.new(array) }

  it 'returns the expected number' do
    expect(subject.number).to eq(10)
  end

  it 'returns the expected format_code' do
    expect(subject.format_code).to eq('IMG')
  end

  describe '.valid_number?' do
    subject { described_class.new(array).valid_number? }

    context 'negative number' do
      let(:array) { %w[-10 IMG] }

      it 'is not valid' do
        expect(subject).to eq(false)
      end
    end

    context 'zero' do
      let(:array) { %w[0 IMG] }

      it 'is not valid' do
        expect(subject).to eq(false)
      end
    end

    context 'positive number' do
      let(:array) { %w[10 IMG] }

      it 'is valid' do
        expect(subject).to eq(true)
      end
    end

    context 'floating point number' do
      let(:array) { %w[4.5 IMG] }

      it 'is not valid' do
        expect(subject).to eq(false)
      end
    end
  end

  describe '.valid_format_code?' do
    subject { described_class.new(array).valid_format_code?(posts) }

    let(:posts) { instance_double(Posts) }

    before do
      allow(posts).to receive(:post_by_format_code).with('IMG').and_return(post)
    end

    context 'when posts returns a post' do
      let(:post) { instance_double(Post) }

      it 'returns true' do
        expect(subject).to eq(true)
      end
    end

    context 'when posts returns nil' do
      let(:post) { nil }

      it 'returns false' do
        expect(subject).to eq(false)
      end
    end
  end
end
