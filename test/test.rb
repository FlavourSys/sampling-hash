require 'minitest/autorun'
require 'minitest/spec'
require 'tempfile'
require 'sampling-hash'

describe 'SamplingHash' do
  describe 'hash' do
    it 'fails if not given a file' do
      assert_raises(ArgumentError) do
        SamplingHash.hash('not-existing', 123)
      end
    end

    it 'uses the file size as default seed' do
      h1 = SamplingHash.hash(__FILE__)
      h2 = SamplingHash.hash(__FILE__, File.size(__FILE__))
      assert_equal h1, h2
    end

    it 'calculates the correct xxhash for a small file' do
      h1 = XXhash.xxh32(File.read(__FILE__), 123)
      h2 = SamplingHash.hash(__FILE__, 123)
      assert_equal h1, h2
    end

    it 'is blazingly fast for large files' do
      Tempfile.open('sampling-hash') do |f|
        f.write '0' * 100000000 # 100 MB.
        SamplingHash.hash(f, 123)
      end
    end
  end
end
