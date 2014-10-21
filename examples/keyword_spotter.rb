#!/usr/bin/env ruby

require "bundler/setup"
require "pocketsphinx-ruby"

include Pocketsphinx

configuration = Configuration::KeywordSpotting.new('hello computer')
recognizer = LiveSpeechRecognizer.new(configuration)

recognizer.recognize do |speech|
  if configuration.keyword == 'hello computer'
    configuration.keyword = 'goodbye computer'
  else
    configuration.keyword = 'hello computer'
  end

  recognizer.reconfigure

  puts "You said '#{speech}'. Keyword is now '#{configuration.keyword}'"
end
