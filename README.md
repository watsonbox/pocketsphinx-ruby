# pocketsphinx-ruby

[![Build Status](http://img.shields.io/travis/watsonbox/pocketsphinx-ruby.svg?style=flat)](https://travis-ci.org/watsonbox/pocketsphinx-ruby)
[![Code Climate](http://img.shields.io/codeclimate/github/watsonbox/pocketsphinx-ruby/badges/gpa.svg?style=flat)](https://codeclimate.com/github/watsonbox/pocketsphinx-ruby)
[![Coverage Status](https://img.shields.io/coveralls/watsonbox/pocketsphinx-ruby.svg?style=flat)](https://coveralls.io/r/watsonbox/pocketsphinx-ruby)

This gem provides Ruby [FFI](https://github.com/ffi/ffi) bindings for [Pocketsphinx](https://github.com/cmusphinx/pocketsphinx), a lightweight speech recognition engine, specifically tuned for handheld and mobile devices, though it works equally well on the desktop. Pocketsphinx is part of the [CMU Sphinx](http://cmusphinx.sourceforge.net/) Open Source Toolkit For Speech Recognition.

I had initially looked at using Pocketsphinx's [SWIG](http://www.swig.org/) interface for this gem, but decided in favor of FFI for many of the reasons outlined [here](https://github.com/ffi/ffi/wiki/Why-use-FFI), but most importantly ease of maintenance and JRuby support.

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


## Basic Usage

The `LiveSpeechRecognizer` is modeled on the same class in [Sphinx4](http://cmusphinx.sourceforge.net/wiki/tutorialsphinx4). It uses the `Microphone` and `Decoder` classes internally to provide a simple, high-level recognition interface:

```ruby
require 'pocketsphinx-ruby'

Pocketsphinx::LiveSpeechRecognizer.new.recognize do |speech|
  puts speech
end
```


## Microphone

The `Microphone` class uses Pocketsphinx's libsphinxad to record audio for speech recognition. For desktop applications this should normally be 16bit/16kHz raw PCM audio, so these are the default settings. The exact audio backend depends on [what was selected](https://github.com/cmusphinx/sphinxbase/blob/master/configure.in#L138) when libsphinxad was built. On OSX, OpenAL is [now supported](https://github.com/cmusphinx/sphinxbase/commit/5cc55c4721273681200e1f754ff0798ac073b950) and should work just fine.

For example, to record and save a 5 second raw audio file:

```ruby
microphone = Microphone.new

File.open("test.raw", "wb") do |file|
  microphone.record do
    FFI::MemoryPointer.new(:int16, 4096) do |buffer|
      50.times do
        sample_count = microphone.read_audio(buffer, 4096)
        file.write buffer.get_bytes(0, sample_count * 2)

        sleep 0.1
      end
    end
  end
end
```


## Contributing

1. Fork it ( https://github.com/[my-github-username]/pocketsphinx-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
