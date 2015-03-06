#!/usr/bin/env ruby

require "bundler/setup"
require "pocketsphinx-ruby"

include Pocketsphinx

decoder = Decoder.new(Configuration.default)
decoder.decode 'spec/assets/audio/goforward.raw'

puts decoder.hypothesis # => "go forward ten meters"