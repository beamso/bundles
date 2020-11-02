require_relative 'spec_helper'
require_relative '../lib/bundle'

RSpec.describe Bundle do
  let(:hash) do
    {
      number: 5,
      cost: 450.0
    }
  end

  subject { described_class.new(hash) }

  it 'has the expected number' do
    expect(subject.number).to eq(5)
  end

  it 'has the expected cost' do
    expect(subject.cost).to eq(450.0)
  end
end
