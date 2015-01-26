require 'minitest/autorun'
require 'minitest/spec'
require 'tempfile'
require 'sampling-hash'
require 'securerandom'

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
      h1 = XXhash.xxh64(File.read(__FILE__), 123)
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

  describe 'Sampler' do
    it 'works' do
      s = SamplingHash::Sampler.new(1000000000, 1000, 0, 1000, 0.001)

      # Size is 1 billion, sample_size is 1000, 1000 samples minimum
      # equals 1 million minimum sampling size, of the remaining 999 million
      # we want 1 one-tenth of a percent, so 999000 (total sampling size)
      # in 1000 + (999000 / 1000) = 1999 samples.
      assert_equal s.size, 1999000
      assert_equal s.samples.size, 1999
    end
  end

  describe 'Hash' do
    it 'works' do
      # I want 1024 Bytes of data and 4 byte sample_size.
      data = SecureRandom.random_bytes(1000)
      sampler = SamplingHash::Sampler.new(1000, 4, 0, 0, 0.1)

      # Expecting 25 samples a 4 byte size = 100 bytes sample data.
      assert_equal sampler.samples.size, 25
      assert_equal sampler.size, 100

      # Sample words are distributed equally over the test data.
      # The gap size will be (1000 - 100) / 25 = 36.
      # Calculate the hash ourselves.
      h1 = XXhash::XXhashInternal::StreamingHash64.new(123)
      25.times { |i| h1.update(data[(i * 40)..(i * 40 + 3)]) }

      # Now use the Hash class.
      h2 = SamplingHash::Hash.new(1000, 123, sampler)

      # We randomly put in 1-50 bytes.
      offset = 0
      while offset < 1000
        chunk = Random.rand(50) + 1
        chunk = [chunk, 1000 - offset].min
        h2.update(data[offset..(offset + chunk - 1)])
        offset += chunk
      end

      assert_equal h1.digest, h2.digest
    end
  end
end
