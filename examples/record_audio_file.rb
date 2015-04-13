#!/usr/bin/env ruby

require "bundler/setup"
require "pocketsphinx-ruby"

include Pocketsphinx

MAX_SAMPLES = 2048
RECORDING_INTERVAL = 0.1
RECORDING_LENGTH = 5

puts "Recording #{RECORDING_LENGTH} seconds of audio..."

microphone = Microphone.new

File.open("test_write.raw", "wb") do |file|
  microphone.record do
    FFI::MemoryPointer.new(:int16, MAX_SAMPLES) do |buffer|
      (RECORDING_LENGTH / RECORDING_INTERVAL).to_i.times do
        sample_count = microphone.read_audio(buffer, MAX_SAMPLES)

        # sample_count * 2 since this is length in bytes
        file.write buffer.get_bytes(0, sample_count * 2)

        sleep RECORDING_INTERVAL
      end
    end
  end
end
