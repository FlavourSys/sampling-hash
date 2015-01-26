require 'sampling-hash/hash'
require 'sampling-hash/sampler'
require 'sampling-hash/sampling-io'
require 'sampling-hash/version'
require 'xxhash'

module SamplingHash
  # We default to 64 bit xxhash.
  def self.hash(path, seed = File.size(path), hash = XXhash::XXhashInternal::StreamingHash64.new(seed))
    raise ArgumentError, 'file not found' unless File.file?(path)

    File.open(path, 'r') do |fd|

      sio = SamplingIO.new(fd)
      sio.samples do |chunk|
        hash.update(chunk)
      end

      hash.digest

    end
  end

  def self.hash32(path, seed = File.size(path))
    hash path, seed, XXHash::XXhashInternal::StreamingHash32.new(seed)
  end

  def self.hash64(path, seed = File.size(path))
    hash path, seed, XXHash::XXhashInternal::StreamingHash64.new(seed)
  end
end
