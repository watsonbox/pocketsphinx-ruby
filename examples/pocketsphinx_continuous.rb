#!/usr/bin/env ruby

require "bundler/setup"
require "pocketsphinx-ruby"

include Pocketsphinx

configuration = Configuration.default
recognizer = LiveSpeechRecognizer.new(configuration)

recognizer.recognize do |speech|
  puts speech
end
