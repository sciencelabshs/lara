shared_examples "attached to embeddable" do
  let(:hidden_open_response_embeddable) { FactoryGirl.create(:hidden_open_response) }
  let(:open_response_embeddable)        { FactoryGirl.create(:open_response) }
  let(:embeddables) { [] }
  let(:page)        { FactoryGirl.create(:page, embeddables: embeddables) }
  let(:args)        { {} }
  let(:test_embeddable) do
    e = described_class.create(args)
    page.add_embeddable(e)
    e.reload
    e
  end

  describe "#possible_embeddables" do
    describe "when there aren't any embeddables" do
      it "should return an empty list" do
        expect(test_embeddable.possible_embeddables).to be_empty
      end
    end

    describe "when there is one invisible embeddables" do
      let(:embeddables) { [hidden_open_response_embeddable] }
      it "should return the hidden embeddable" do
        expect(test_embeddable.possible_embeddables).to include hidden_open_response_embeddable
      end
    end

    describe "when there is one visibile and one invisible embeddable" do
      let(:embeddables) { [hidden_open_response_embeddable, open_response_embeddable] }
      it "should return both of them" do
        expect(test_embeddable.possible_embeddables).to include open_response_embeddable
        expect(test_embeddable.possible_embeddables).to include hidden_open_response_embeddable
      end
    end
  end

  describe "#embeddables_for_select" do
    let(:embeddable_a)         { FactoryGirl.create(:open_response) }
    let(:embeddable_b)         { FactoryGirl.create(:open_response) }

    let(:expected_identifier_1) { AttachedToEmbeddable::NO_EMBEDDABLE_SELECT }
    let(:expected_identifier_2) { ["Open response (1)", "#{embeddable_a.id}-Embeddable::OpenResponse"]}
    let(:expected_identifier_3) { ["Open response (2)", "#{embeddable_b.id}-Embeddable::OpenResponse"]}
    let(:expected_identifier_4) { ["Open response (hidden)(3)", "#{hidden_open_response_embeddable.id}-Embeddable::OpenResponse"]}

    let(:embeddables) { [embeddable_a, embeddable_b, hidden_open_response_embeddable] }
    it "should have good options" do
      expect(test_embeddable.embeddables_for_select).to include expected_identifier_1
      expect(test_embeddable.embeddables_for_select).to include expected_identifier_2
      expect(test_embeddable.embeddables_for_select).to include expected_identifier_3
      expect(test_embeddable.embeddables_for_select).to include expected_identifier_3
    end
  end
end
