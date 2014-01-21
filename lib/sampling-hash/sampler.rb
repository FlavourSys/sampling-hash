module SamplingHash
  class Sampler
    include Enumerable

    attr_reader :samples, :size

    # Calculates sample offsets.
    # 
    # Parameters:
    # - sample_size: Size of a sample (in bytes).
    # - header_samples: Number of samples at front of data always to be included.
    # - minimum_samples: Minimum number of samples to be included.
    # - remaining_factor: If size is greater than minimum_samples * sample_size, this specifies the
    #              linear factor function used to determine the additional data used.
    def initialize(size, sample_size = 1024, header_samples = 1000, minimum_samples = 5000, remaining_factor = 0.001)
      @samples = []

      minimum_sampling_size = minimum_samples * sample_size
      if (size > minimum_sampling_size)
        # Continuous header samples first.
        header_samples.times { |i| @samples << [i * sample_size, sample_size] }

        # Spread the rest.
        start_offset                       = header_samples * sample_size
        remaining_size                     = size - start_offset

        remaining_minimum_samples          = [0, minimum_samples - header_samples].max
        remaining_minimum_sampling_size    = remaining_minimum_samples * sample_size

        remaining_additional_size          = remaining_size - remaining_minimum_sampling_size
        remaining_additional_sampling_size = remaining_additional_size * remaining_factor
        remaining_additional_samples       = (remaining_additional_sampling_size / sample_size).truncate

        remaining_total_samples            = remaining_minimum_samples + remaining_additional_samples
        remaining_total_sampling_size      = remaining_minimum_sampling_size + remaining_additional_sampling_size

        remaining_unsampled_size           = remaining_size - remaining_total_sampling_size
        remaining_sampling_gap             = (remaining_unsampled_size / remaining_total_samples).truncate

        # NOTE: We can not overflow since we calculated the remaining_additional_samples with integer division.
        remaining_total_samples.times do |i|
          @samples << [start_offset + i * (sample_size + remaining_sampling_gap), sample_size]
        end
      else
        total_full_samples = size / sample_size
        last_sample_size   = size - ((size / sample_size) * sample_size)

        # Simply take them all.
        total_full_samples.times { |i| @samples << [i * sample_size, sample_size] }
        @samples << [total_full_samples * sample_size, last_sample_size] if last_sample_size != 0
      end

      @size = @samples.inject(0) { |i, v| i + v[1] }
    end

    def each(&block)
      @samples.each(&block)
    end
  end
end
