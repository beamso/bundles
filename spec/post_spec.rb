require_relative 'spec_helper'
require_relative '../lib/post'
require_relative '../lib/bundle'

RSpec.describe Post do
  let(:hash) do
    {
      submission_format: 'Image',
      format_code: 'IMG',
      bundles: [
        {
          number: 5,
          cost: 450.0
        },
        {
          number: 10,
          cost: 800.0
        }
      ]
    }
  end

  subject { described_class.new(hash) }

  it 'has the expected submission_format' do
    expect(subject.submission_format).to eq('Image')
  end

  it 'has the expected format_code' do
    expect(subject.format_code).to eq('IMG')
  end

  it 'has two bundles' do
    expect(subject.bundles.count).to eq(2)
  end

  it 'has the expected class of bundle' do
    expect(subject.bundles).to all(be_a(Bundle))
  end

  it 'has the expected number on the first bundle' do
    expect(subject.bundles.first.number).to eq(5)
  end

  it 'has the expected cost on the last bundle' do
    expect(subject.bundles.last.cost).to eq(800.0)
  end

  context 'with no bundles' do
    let(:hash) do
      {
        submission_format: 'Image',
        format_code: 'IMG'
      }
    end

    it 'has zero bundles' do
      expect(subject.bundles).to be_empty
    end
  end
end
