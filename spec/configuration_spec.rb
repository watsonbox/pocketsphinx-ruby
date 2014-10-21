require 'spec_helper'

describe Configuration do
  subject { Pocketsphinx::Configuration.default }

  it "provides a default pocketsphinx configuration" do
    expect(subject).to be_a(Pocketsphinx::Configuration::Default)
  end

  it "supports integer settings" do
    expect(subject['frate']).to eq(100)
    expect(subject['frate']).to be_a(Fixnum)

    subject['frate'] = 50
    expect(subject['frate']).to eq(50)

    expect { subject['frate'] = nil }.to raise_exception "Only string settings can be set to nil"
  end

  it "supports float settings" do
    expect(subject['samprate']).to eq(16000)
    expect(subject['samprate']).to be_a(Float)

    subject['samprate'] = 8000
    expect(subject['samprate']).to eq(8000)

    expect { subject['samprate'] = nil }.to raise_exception "Only string settings can be set to nil"
  end

  it "supports string settings" do
    expect(subject['warp_type']).to eq('inverse_linear')

    subject['warp_type'] = 'different_type'
    expect(subject['warp_type']).to eq('different_type')

    subject['warp_type'] = nil
    expect(subject['warp_type']).to eq(nil)
  end

  it "supports boolean settings" do
    expect(subject['smoothspec']).to eq(false)

    subject['smoothspec'] = true
    expect(subject['smoothspec']).to eq(true)

    expect { subject['smoothspec'] = nil }.to raise_exception "Only string settings can be set to nil"
  end

  it 'raises exceptions when setting with incorrectly typed values' do
    expect { subject['frate'] = true }.to raise_exception "Configuration setting 'frate' must be of type Integer"
  end

  it 'raises exceptions when a setting is unknown' do
    expect { subject['unknown'] = true }.to raise_exception "Configuration setting 'unknown' does not exist"
  end

  describe '#setting_names' do
    it 'contains the names of all possible system settings' do
      expect(subject.setting_names.count).to eq(117)
    end
  end

  describe '#details' do
    it 'gives details for a single setting' do
      expect(subject.details 'vad_threshold').to eq({
        name: "vad_threshold",
        type: :float,
        default: 2.0,
        required: false,
        value: 2.0,
        info: "Threshold for decision between noise and silence frames. Log-ratio between signal level and noise level."
      })
    end

    it 'gives details for all settings when no name is specified' do
      details = subject.details

      expect(details.count).to eq(117)
      expect(details.first).to eq({
        name: "agc",
        type: :string,
        default: "none",
        required: false,
        value: "none",
        info: "Automatic gain control for c0 ('max', 'emax', 'noise', or 'none')"
      })
    end
  end

  context 'keyword spotting configuration' do
    subject { Configuration::KeywordSpotting.new('Okay computer') }

    it 'sets the lowercase keyphrase' do
      expect(subject['keyphrase']).to eq('okay computer')
    end

    it 'uses no language model' do
      expect(subject['lm']).to be_nil
    end
  end
end
