require_relative 'spec_helper'
require_relative '../lib/posts'
require_relative '../lib/fulfilled_order_item'
require_relative '../lib/fulfilled_order_item_printer'

RSpec.describe FulfilledOrderItemPrinter do
  let(:json_filename) { File.join(File.dirname(__FILE__), 'fixtures', 'posts.json') }
  let(:posts) { Posts.new(json_filename) }
  let(:post) { posts.post_by_format_code('VID') }
  let(:fulfilled_order_item) { FulfilledOrderItem.new(post, 13) }
  let(:instance) { described_class.new }

  before do
    fulfilled_order_item.increment_bundle_size(5)
    fulfilled_order_item.increment_bundle_size(5)
    fulfilled_order_item.increment_bundle_size(3)
    allow(instance).to receive(:puts)
  end

  subject { instance.print(fulfilled_order_item) }

  it 'prints the expected text' do
    expect(instance).to receive(:puts).with(
      <<~ENDOFTEXT
        13 VID $2370.00
         1 x 3 $570.00
         2 x 5 $1800.00

      ENDOFTEXT
    )
    subject
  end

  context 'incomplete bundle' do
    before do
      fulfilled_order_item.increment_bundle_size(3)
    end

    it 'does not print anything' do
      expect(instance).to_not receive(:puts)
      subject
    end
  end
end
