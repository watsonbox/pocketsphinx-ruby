require 'ffi'

require "pocketsphinx/version"

# Pocketsphinx FFI API
require "pocketsphinx/api/sphinxbase"
require "pocketsphinx/api/sphinxad"
require "pocketsphinx/api/pocketsphinx"
require "pocketsphinx/api/call_helpers"

# Grammar
require "pocketsphinx/grammar/jsgf"
require "pocketsphinx/grammar/jsgf_builder"

# Configuration
require "pocketsphinx/configuration/setting_definition"
require "pocketsphinx/configuration/base"
require "pocketsphinx/configuration/default"
require "pocketsphinx/configuration/keyword_spotting"
require "pocketsphinx/configuration/grammar"

require "pocketsphinx/audio_file"
require "pocketsphinx/microphone"
require "pocketsphinx/decoder"
require "pocketsphinx/speech_recognizer"
require "pocketsphinx/live_speech_recognizer"
require "pocketsphinx/audio_file_speech_recognizer"

module Pocketsphinx
  def self.disable_logging
    API::Sphinxbase.err_set_logfp(nil)
  end
end
