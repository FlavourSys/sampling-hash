require 'sampling-hash/hash'
require 'sampling-hash/sampler'
require 'sampling-hash/sampling-io'
require 'sampling-hash/version'
require 'xxhash'

module SamplingHash
  def self.hash(path, seed = File.size(path))
    raise ArgumentError, 'file not found' unless File.file?(path)

    hash = XXhash::Internal::StreamingHash.new(seed)

    File.open(path, 'r') do |fd|

      sio = SamplingIO.new(fd)
      sio.samples do |chunk|
        hash.update(chunk)
      end

      hash.digest

    end
  end
end
