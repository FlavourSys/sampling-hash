module SamplingHash
  class SamplingIO
    def initialize(io, sampler = nil)
      raise ArgumentError, 'first parameter should be IO' unless io.kind_of?(IO)

      @io = io
      @sampler = sampler || Sampler.new(io.stat.size)
    end

    def samples
      @sampler.each do |offset, size|
        @io.seek(offset, IO::SEEK_SET)
        yield @io.read(size)
      end
    end
  end
end
