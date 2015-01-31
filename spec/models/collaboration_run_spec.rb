require 'spec_helper'

describe CollaborationRun do
  let(:user1)    { FactoryGirl.create(:user) }
  let(:user2)    { FactoryGirl.create(:user) }
  let(:user3)    { FactoryGirl.create(:user) }
  let(:activity) { FactoryGirl.create(:activity_with_page_and_or) }
  # There is no need to test other types of questions, as answer copying / duplication is handled
  # in their separate unit tests.
  let(:or_question) { activity.questions[0] }
  let(:or_answer1)  { FactoryGirl.create(:or_answer, { answer_text: "the answer", question: or_question }) }
  let(:or_answer2)  { FactoryGirl.create(:or_answer, { answer_text: "the different answer", question: or_question }) }

  let(:run1) {
    r = FactoryGirl.create(:run)
    r.activity = activity
    r.user = user1
    r
  }
  let(:finder1) { Embeddable::AnswerFinder.new(run1) }
  let(:run2) {
    r = FactoryGirl.create(:run)
    r.activity = activity
    r.user = user2
    r
  }
  let(:finder2) { Embeddable::AnswerFinder.new(run2) }
  let(:run3) {
    r = FactoryGirl.create(:run)
    r.activity = activity
    r.user = user3
    r
  }
  let(:finder3) { Embeddable::AnswerFinder.new(run3) }
  let(:collaboration_run) {
    cr = FactoryGirl.create(:collaboration_run)
    cr.user = user1
    cr.runs << run1
    cr.runs << run2
    cr.runs << run3
    cr
  }

  describe "class methods" do
    describe "#already_created?" do
      it "should return true if run already exists" do
        expect(CollaborationRun.already_created?(collaboration_run.collaborators_data_url)).to eq(true)
      end
    end
    describe "#lookup" do
      it "should return run using endpoint URL" do
        expect(CollaborationRun.lookup(collaboration_run.collaborators_data_url)).to eq(collaboration_run)
      end
    end
  end

  describe "#propagate_answer" do
    it "should copy an answer to all the collaborators runs" do
      # User1 and user2 provided different answers, user3 didn't provide any.
      run1.open_response_answers << or_answer1
      run2.open_response_answers << or_answer2
      # Propagate user1's answer. User2's answer should be overwritten, while answer for user3
      # should be created.
      collaboration_run.propagate_answer(or_answer1)

      expect(run1.open_response_answers.count).to eq(1)
      expect(run2.open_response_answers.count).to eq(1)
      expect(run3.open_response_answers.count).to eq(1)
      expect(finder1.find_answer(or_question).answer_text).to eq(or_answer1.answer_text)
      expect(finder2.find_answer(or_question).answer_text).to eq(or_answer1.answer_text)
      expect(finder3.find_answer(or_question).answer_text).to eq(or_answer1.answer_text)
    end

    describe "when runs are related to different activities (e.g. during sequence collaboration)" do
      before do
        another_activity = FactoryGirl.create(:activity)
        run3.activity = another_activity
        run3.save
      end

      it "should copy an answer to another run only if this run is related to the same activity" do
        # Only user1 provided answer.
        run1.open_response_answers << or_answer1
        # Propagate user1's answer. User2's answer should be created, while answer for user3
        # should NOT be created, as this run is related to some different activity.
        collaboration_run.propagate_answer(or_answer1)

        expect(run1.open_response_answers.count).to eq(1)
        expect(run2.open_response_answers.count).to eq(1)
        expect(run3.open_response_answers.count).to eq(0) # different activity!
        expect(finder1.find_answer(or_question).answer_text).to eq(or_answer1.answer_text)
        expect(finder2.find_answer(or_question).answer_text).to eq(or_answer1.answer_text)
      end
    end
  end

  describe "#owners_run" do
    it "should return run owned by the collaboration owner" do
      expect(collaboration_run.owners_run(activity)).to eq(run1)
    end
  end
end
