require 'spec_helper'

describe Pocketsphinx::Grammar::Jsgf do
  it "raises an exception when neither a file or block are given" do
    expect { Pocketsphinx::Grammar::Jsgf.new(nil) }.to raise_exception "a raw grammar has to be given"
  end

  context "reading a grammar from a file" do
    let(:grammar_path) { grammar :goforward }
    subject { Pocketsphinx::Grammar::JsgfFile.new(grammar_path) }

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

  context "reading a grammar from a string" do

    it "reads a grammar from a string" do
      grammar=Pocketsphinx::Grammar::JsgfString.new("#JSGF V1.0;\ngrammar default;\npublic <sentence> = Go forward ten meters")
      expect(grammar.raw.lines.count).to eq(3)
    end

    context "the grammar string is invalid" do
      it "raises an exception" do
        expect { Pocketsphinx::Grammar::JsgfString.new("This Grammar is invalid") }.to raise_exception "Invalid JSGF grammar"
      end
    end
  end

  context "building a grammer from a block" do
    subject do
      jsgf = Pocketsphinx::Grammar::JsgfSentences.new do
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
