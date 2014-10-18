require 'spec_helper'

describe Pocketsphinx::Configuration do
  subject { Pocketsphinx::Configuration.default }

  it "provides a default pocketsphinx configuration" do
    expect(subject).to be_a(Pocketsphinx::Configuration)
  end

  it "supports integer settings" do
    expect(subject['frate']).to eq(100)
    expect(subject['frate']).to be_a(Fixnum)

    subject['frate'] = 50
    expect(subject['frate']).to eq(50)
  end

  it "supports float settings" do
    expect(subject['samprate']).to eq(16000)
    expect(subject['samprate']).to be_a(Float)

    subject['samprate'] = 8000
    expect(subject['samprate']).to eq(8000)
  end

  it "supports getting strings" do
    expect(subject['warp_type']).to eq('inverse_linear')

    subject['warp_type'] = 'different_type'
    expect(subject['warp_type']).to eq('different_type')
  end

  it "supports getting booleans" do
    expect(subject['smoothspec']).to eq(false)

    subject['smoothspec'] = true
    expect(subject['smoothspec']).to eq(true)
  end

  it 'raises exceptions when setting with incorrectly typed values' do
    expect { subject['frate'] = true }.to raise_exception "Configuration setting 'frate' must be a Fixnum"
  end

  it 'raises exceptions when a setting is unknown' do
    expect { subject['unknown'] = true }.to raise_exception "Configuration setting 'unknown' does not exist"
  end
end
