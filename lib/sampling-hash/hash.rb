module SamplingHash
  class Hash
    def initialize(size, seed = size, sampler = nil)
      @sampler = sampler || Sampler.new(size)
      @xxhash = XXhash::Internal::StreamingHash.new(seed)
      
      # Position in data stream.
      @position = 0

      # Current sample.
      @current_sample        = nil # The data.
      @current_sample_offset = 0   # The offset (within the stream).
      @current_sample_size   = 0   # The sample size.
      @next                  = 0   # The next sample index.

      # Start.
      next_sample
    end

    def update(chunk)
      pos = 0
      while pos < chunk.size
        len = chunk.size - pos
        used = advance(chunk, pos, len)
        @position += used
        pos += used
      end
    end

    def digest
      @xxhash.digest
    end

  private

    def advance(chunk, pos, len)
      if in_sample?
        # Use some bytes.
        msb = missing_sample_bytes
        if msb > len
          update_sample chunk[pos..(pos + len - 1)]
          len
        else
          finish_sample chunk[pos..(pos + msb - 1)]
          msb
        end
      elsif samples_left?
        # Discard some bytes until the next sample starts.
        mgb = missing_gap_bytes
        if mgb > len
          len
        else
          mgb
        end
      else
        # Discard the rest.
        len
      end
    end

    def in_sample?
      samples_left? && @position >= @current_sample_offset && @position < @current_sample_offset + @current_sample_size
    end

    def samples_left?
      !!@current_sample
    end

    def missing_sample_bytes
      @current_sample_size - @current_sample.size
    end

    def missing_gap_bytes
      @current_sample_offset - @position
    end

    def update_sample(data)
      @current_sample += data
    end

    def finish_sample(data)
      @current_sample += data
      @xxhash.update(@current_sample)
      next_sample
    end

    def next_sample
      if @next < @sampler.samples.size
        @current_sample = String.new
        @current_sample_offset, @current_sample_size = @sampler.samples[@next]
        @next += 1
      else
        @current_sample = nil
      end
    end
  end
end
