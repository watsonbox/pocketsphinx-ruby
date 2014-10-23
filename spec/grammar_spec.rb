require 'spec_helper'

describe Grammar::Jsgf do
  let(:grammar_path) { grammar :goforward }
  subject { Grammar::Jsgf.new(grammar_path) }

  it "reads a grammar from a file" do
    expect(subject.raw.lines.count).to eq(15)
  end

  context "the grammar file is invalid" do
    let(:grammar_path) { grammar :invalid }

    it "raises an exception" do
      expect { subject }.to raise_exception "Invalid JSGF grammar"
    end
  end

  private

  def grammar(name)
    "spec/assets/grammars/#{name}.gram"
  end
end
