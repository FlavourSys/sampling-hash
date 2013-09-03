module SamplingHash
  class SamplingIO
    def initialize(io)
      raise ArgumentError, 'first parameter should be IO' unless io.kind_of?(IO)

      @io = io
      @chunk = 0
    end

    def sample
      return nil if @chunk > samples

      @io.seek(offset, IO::SEEK_SET)
      @chunk += 1
      @io.read(CHUNK_SIZE)
    end

  private

    CHUNK_SIZE = 256

    def file_size
      @file_size ||= @io.stat.size
    end

    def reduce
      (Math.log(file_size / 1000) * 1000).truncate & 0xFFFFFF00
    end

    def samples_size
      @samples_size ||= (file_size < 3000 ? file_size : reduce)
    end

    def samples
      samples_size / CHUNK_SIZE + 1
    end

    def offset
      @chunk * CHUNK_SIZE
    end
  end
end
