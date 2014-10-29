require 'spec_helper'

describe Pocketsphinx::Grammar::Jsgf do
  it "raises an exception when neither a file or block are given" do
    expect { Pocketsphinx::Grammar::Jsgf.new }.to raise_exception "Either a path or block is required to create a JSGF grammar"
  end

  context "reading a grammar from a file" do
    let(:grammar_path) { grammar :goforward }
    subject { Pocketsphinx::Grammar::Jsgf.new(grammar_path) }

    it "reads a grammar from a file" do
      expect(subject.raw.lines.count).to eq(15)
    end

    context "the grammar file is invalid" do
      let(:grammar_path) { grammar :invalid }

      it "raises an exception" do
        expect { subject }.to raise_exception "Invalid JSGF grammar"
      end
    end
  end

  context "building a grammer from a block" do
    subject do
      Pocketsphinx::Grammar::Jsgf.new do
        sentence "Go forward ten meters"
        sentence "Go backward ten meters"
      end
    end

    it "builds a grammar from a block" do
      expect(subject.raw).to eq(File.read grammar(:sentences))
    end
  end

  private

  def grammar(name)
    "spec/assets/grammars/#{name}.gram"
  end
end
