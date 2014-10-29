require 'spec_helper'

describe Pocketsphinx::LiveSpeechRecognizer do
  it 'uses the microphone for audio input' do
    expect(Pocketsphinx::Microphone).to receive(:new).and_return(:microphone)
    expect(Pocketsphinx::LiveSpeechRecognizer.new.recordable).to eq(:microphone)
  end
end
