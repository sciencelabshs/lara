require 'spec_helper'

describe Embeddable::OpenResponseAnswer do
  let(:question) { FactoryGirl.create(:or_embeddable) }
  let(:answer) { Embeddable::OpenResponseAnswer.create({ :answer_text => "the answer", :question => question }) }

  describe "model associations" do

    it "should belong to an open response" do
      question = Embeddable::OpenResponse.create()
      answer.question = question
      answer.save
      answer.reload.question.should == question
      question.reload.answers.should include answer
    end

    it "should belong to a run" do
      run = Run.create(:activity => FactoryGirl.create(:activity))
      answer.run = run
      answer.save
      answer.reload.run.should == run
      run.reload.open_response_answers.should include answer
    end
  end

  describe '#to_json' do
    let(:expected) { '{ "type": "open_response", "question_id": "' + question.id.to_s + '", "answer": "the answer" }' }

    it "serializes to expected JSON" do
      JSON.parse(answer.to_json).should == JSON.parse(expected)
    end
  end

  describe "delegated methods" do
    describe "prompt" do
      it "should delegate to question" do
        question = mock_model(Embeddable::OpenResponse)
        question.should_receive(:prompt).and_return(:some_prompt)
        answer.question = question
        answer.prompt.should == :some_prompt
      end
    end
  end

end
