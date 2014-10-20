module Pocketsphinx
  # Implements Recordable interface (#record and #read_audio)
  class AudioFile < Struct.new(:file_path)
    def record
      File.open(file_path, 'rb') do |file|
        self.file = file
        yield
        self.file = nil
      end
    end

    # Read next block of audio samples from file; up to max samples into buffer.
    #
    # @param [FFI::Pointer] buffer 16bit buffer of at least max_samples in size
    # @params [Fixnum] max_samples The maximum number of samples to read from the audio file
    # @return [Fixnum] Samples actually read; nil if EOF
    def read_audio(buffer, max_samples = 4096)
      if file.nil?
        raise "Can't read audio: use AudioFile#record to open the file first"
      end

      if data = file.read(max_samples * 2)
        buffer.write_string(data)
        data.length / 2
      end
    end

    private

    attr_accessor :file
  end
end
