require 'spec_helper'

describe LiveSpeechRecognizer do
  it 'uses the microphone for audio input' do
    expect(Microphone).to receive(:new).and_return(:microphone)
    expect(LiveSpeechRecognizer.new.recordable).to eq(:microphone)
  end
end
