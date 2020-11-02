require_relative 'spec_helper'
require_relative '../lib/post'
require_relative '../lib/posts'

RSpec.describe Posts do
  let(:json_filename) do
    File.join(File.dirname(__FILE__), 'fixtures', 'posts.json')
  end

  subject { described_class.new(json_filename) }

  it 'has three posts' do
    expect(subject.posts.count).to eq(3)
  end

  it 'has post that are all posts' do
    expect(subject.posts).to all(be_a(Post))
  end

  it 'has an IMG post' do
    expect(subject.post_by_format_code('IMG')).to_not be_nil
  end

  it 'has an FLAC post' do
    expect(subject.post_by_format_code('FLAC')).to_not be_nil
  end

  it 'has an VID post' do
    expect(subject.post_by_format_code('VID')).to_not be_nil
  end

  it 'does not have a TXT post' do
    expect(subject.post_by_format_code('TXT')).to be_nil
  end

  context 'when file does not exist' do
    let(:json_filename) do
      File.join(File.dirname(__FILE__), 'fixtures', 'unknown.json')
    end

    it 'raises an error' do
      expect { subject }.to raise_error(Errno::ENOENT)
    end
  end
end
