module Pocketsphinx
  # Implements Recordable interface (#start_recording, #stop_recording and #read_audio)
  class AudioFile < Struct.new(:file_path)
    # Read next block of audio samples from file; up to max samples into buffer.
    #
    # @param [FFI::Pointer] buffer 16bit buffer of at least max_samples in size
    # @params [Fixnum] max_samples The maximum number of samples to read from the audio file
    # @return [Fixnum] Samples actually read; nil if EOF
    def read_audio(buffer, max_samples = 2048)
      if file.nil?
        raise "Can't read audio: use AudioFile#start_recording to open the file first"
      end

      if data = file.read(max_samples * 2)
        buffer.write_string(data)
        data.length / 2
      end
    end

    def start_recording
      self.file = File.open(file_path, 'rb')
    end

    def stop_recording
      if file
        file.close
        self.file = nil
      end
    end

    private

    attr_accessor :file
  end
end
