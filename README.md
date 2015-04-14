# pocketsphinx-ruby

[![Build Status](http://img.shields.io/travis/watsonbox/pocketsphinx-ruby.svg?style=flat)](https://travis-ci.org/watsonbox/pocketsphinx-ruby)
[![Code Climate](http://img.shields.io/codeclimate/github/watsonbox/pocketsphinx-ruby/badges/gpa.svg?style=flat)](https://codeclimate.com/github/watsonbox/pocketsphinx-ruby)
[![Coverage Status](https://img.shields.io/coveralls/watsonbox/pocketsphinx-ruby.svg?style=flat)](https://coveralls.io/r/watsonbox/pocketsphinx-ruby)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg?style=flat)](http://www.rubydoc.info/gems/pocketsphinx-ruby/frames)

This gem provides Ruby [FFI](https://github.com/ffi/ffi) bindings for [Pocketsphinx](https://github.com/cmusphinx/pocketsphinx), a lightweight speech recognition engine, specifically tuned for handheld and mobile devices, though it works equally well on the desktop. Pocketsphinx is part of the [CMU Sphinx](http://cmusphinx.sourceforge.net/) Open Source Toolkit For Speech Recognition.

Pocketsphinx's [SWIG](http://www.swig.org/) interface was initially considered for this gem, but dropped in favor of FFI for many of the reasons outlined [here](https://github.com/ffi/ffi/wiki/Why-use-FFI); most importantly ease of maintenance and JRuby support.

The goal of this project is to make it as easy as possible for the Ruby community to experiment with speech recognition. Please do contribute fixes and enhancements.


## Installation

This gem depends on [Pocketsphinx](https://github.com/cmusphinx/pocketsphinx) (libpocketsphinx), and [Sphinxbase](https://github.com/cmusphinx/sphinxbase) (libsphinxbase and libsphinxad). The current stable versions (0.8) are from late 2012 and are now outdated. Build them manually from source, or on OSX the latest development (potentially unstable) versions can be installed using [Homebrew](http://brew.sh/) as follows ([more information here](https://github.com/watsonbox/homebrew-cmu-sphinx)).

Add the Homebrew tap:

```bash
$ brew tap watsonbox/cmu-sphinx
```

You'll see some warnings as these formulae conflict with those in the main reponitory, but that's fine.

Install the libraries:

```bash
$ brew install --HEAD watsonbox/cmu-sphinx/cmu-sphinxbase
$ brew install --HEAD watsonbox/cmu-sphinx/cmu-sphinxtrain # optional
$ brew install --HEAD watsonbox/cmu-sphinx/cmu-pocketsphinx
```

You can test continuous recognition as follows:

```bash
$ pocketsphinx_continuous -inmic yes
```

Then add this line to your application's Gemfile:

    gem 'pocketsphinx-ruby'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pocketsphinx-ruby


## Usage

The `LiveSpeechRecognizer` is modeled on the same class in [Sphinx4](http://cmusphinx.sourceforge.net/wiki/tutorialsphinx4). It uses the `Microphone` and `Decoder` classes internally to provide a simple, high-level recognition interface:

```ruby
require 'pocketsphinx-ruby' # Omitted in subsequent examples

Pocketsphinx::LiveSpeechRecognizer.new.recognize do |speech|
  puts speech
end
```

The `AudioFileSpeechRecognizer` decodes directly from an audio file by coordinating interactions between an `AudioFile` and `Decoder`.

```ruby
recognizer = Pocketsphinx::AudioFileSpeechRecognizer.new

recognizer.recognize('spec/assets/audio/goforward.raw') do |speech|
  puts speech # => "go forward ten meters"
end
```

These two classes split speech into utterances by detecting silence between them. By default this uses Pocketsphinx's internal Voice Activity Detection (VAD) which can be configured by adjusting the `vad_postspeech`, `vad_prespeech`, and `vad_threshold` configuration settings.


### Configuration

All of Pocketsphinx's decoding settings are managed by the `Configuration` class, which can be passed into the high-level speech recognizers:

```ruby
configuration = Pocketsphinx::Configuration.default
configuration.details('vad_threshold')
# => {
#   :name => "vad_threshold",
#   :type => :float,
#   :default => 2.0,
#   :value => 2.0,
#   :info => "Threshold for decision between noise and silence frames. Log-ratio between signal level and noise level."
# }

configuration['vad_threshold'] = 4

Pocketsphinx::LiveSpeechRecognizer.new(configuration)
```

You can find the output of `configuration.details` [here](https://github.com/watsonbox/pocketsphinx-ruby/wiki/Default-Pocketsphinx-Configuration) for more information on the various different settings.


### Microphone

The `Microphone` class uses Pocketsphinx's libsphinxad to record audio for speech recognition. For desktop applications this should normally be 16bit/16kHz raw PCM audio, so these are the default settings. The exact audio backend depends on [what was selected](https://github.com/cmusphinx/sphinxbase/blob/master/configure.in#L138) when libsphinxad was built. On OSX, OpenAL is [now supported](https://github.com/cmusphinx/sphinxbase/commit/5cc55c4721273681200e1f754ff0798ac073b950) and should work just fine.

For example, to record and save a 5 second raw audio file:

```ruby
microphone = Pocketsphinx::Microphone.new

File.open("test.raw", "wb") do |file|
  microphone.record do
    FFI::MemoryPointer.new(:int16, 2048) do |buffer|
      50.times do
        sample_count = microphone.read_audio(buffer, 2048)
        file.write buffer.get_bytes(0, sample_count * 2)

        sleep 0.1
      end
    end
  end
end
```

To open this audio file take a look at [this wiki page](https://github.com/watsonbox/pocketsphinx-ruby/wiki/Importing-raw-PCM-audio-with-Audacity).


### Decoder

The `Decoder` class uses Pocketsphinx's libpocketsphinx to decode audio data into text. For example to decode a single utterance:

```ruby
decoder = Pocketsphinx::Decoder.new(Pocketsphinx::Configuration.default)
decoder.decode 'spec/assets/audio/goforward.raw'

puts decoder.hypothesis # => "go forward ten meters"
```

And split into individual words with frame data:

```ruby
decoder.words
# => [
#  #<struct Pocketsphinx::Decoder::Word word="<s>", start_frame=608, end_frame=610>,
#  #<struct Pocketsphinx::Decoder::Word word="go", start_frame=611, end_frame=622>,
#  #<struct Pocketsphinx::Decoder::Word word="forward", start_frame=623, end_frame=675>,
#  #<struct Pocketsphinx::Decoder::Word word="ten", start_frame=676, end_frame=711>,
#  #<struct Pocketsphinx::Decoder::Word word="meters", start_frame=712, end_frame=770>,
#  #<struct Pocketsphinx::Decoder::Word word="</s>", start_frame=771, end_frame=821>
# ]
```

Note: When the `Decoder` is initialized, the supplied `Configuration` is updated by Pocketsphinx with some settings from the acoustic model. To see exactly what's going on:

```ruby
Pocketsphinx::Decoder.new(Pocketsphinx::Configuration.default).configuration.changes
```


### Keyword Spotting

Keyword spotting is another feature that is not in the current stable (0.8) releases of Pocketsphinx, having been [merged into trunk](https://github.com/cmusphinx/pocketsphinx/commit/f562f9356cc7f1ade4941ebdde0c377642a023e3) early in 2014. It can be useful for detecting an activation keyword in a command and control application, while ignoring all other speech. Set up a recognizer as follows:

```ruby
configuration = Pocketsphinx::Configuration::KeywordSpotting.new('Okay computer')
recognizer = Pocketsphinx::LiveSpeechRecognizer.new(configuration)
```

The `KeywordSpotting` configuration accepts a second argument for adjusting the sensitivity of the keyword detection. Note that this is just a wrapper which sets the `keyphrase` and `kws_threshold` settings on the default configuration, and removes the language model:

```ruby
Pocketsphinx::Configuration::KeywordSpotting.new('keyword', 2).changes
# => [
#   { :name => "keyphrase", :type => :string, :default => nil, :required => false, :value => "keyword", :info => "Keyphrase to spot" },
#   { :name => "kws_threshold", :type => :float, :default => 1.0, :required => false, :value => 2.0, :info => "Threshold for p(hyp)/p(alternatives) ratio" },
#   { :name => "lm", :type => :string, :default => "/usr/local/Cellar/cmu-pocketsphinx/HEAD/share/pocketsphinx/model/lm/en_US/hub4.5000.DMP", :required => false, :value => nil, :info => "Word trigram language model input file" }
# ]
```


### Grammars

Another way of configuring Pocketsphinx is with a grammar, which is normally used to describe very simple types of languages for command and control. Restricting the set of possible utterances in this way can greatly improve recognition accuracy for these types of application.

Load a [JSGF](http://www.w3.org/TR/jsgf/) grammar from a file:

```ruby
configuration = Pocketsphinx::Configuration::Grammar.new('sentences.gram')
```

Or build one dynamically with this simple DSL (currently only supports sentence lists):

```ruby
configuration = Pocketsphinx::Configuration::Grammar.new do
  sentence "Go forward ten meters"
  sentence "Go backward ten meters"
end
```

## Recognition Accuracy and Training

See the CMU Sphinx resources on [training](http://cmusphinx.sourceforge.net/wiki/tutorialam) and [adapting](http://cmusphinx.sourceforge.net/wiki/tutorialadapt) acoustic models for more information.

[Peter Grasch](http://grasch.net/), author of [Simon](https://simon.kde.org/), has also made a number of interesting posts on the [state of open source speech recognition](http://grasch.net/node/19), as wells as improving [language](http://grasch.net/node/20) and [acoustic](http://grasch.net/node/21) models.

See [`sphinxtrain-ruby`](https://github.com/watsonbox/sphinxtrain-ruby) for an experimental toolkit for training/adapting CMU Sphinx acoustic models. Its main goal is to help with adapting existing acoustic models to a specific speaker/accent.


## Troubleshooting

First and foremost, because this gem **depends on development versions** of CMU Sphinx packages, there will be times when errors are caused by API changes or bugs in those packages. Unfortunately until some up to date releases are made this is going to happen from time to time, so please do open an issue with as much detail as you have.

This gem has been tested with a manual Pocketsphinx installation on Ubuntu 14.04 and a Homebrew Pocketsphinx installation on OSX 10.9.4 Mavericks. Take a look at the following common problems before opening an issue.

**`attach_function': Function 'ps_default_search_args' not found in [libpocketsphinx.so] (FFI::NotFoundError)**

An error like this probably means that you have an old version of the Pocketsphinx libraries installed. If necessary, replace them with a recent development version which supports the features available in this gem.


## Contributing

1. Fork it ( https://github.com/watsonbox/pocketsphinx-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
