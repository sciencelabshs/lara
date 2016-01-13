require 'spec_helper'

describe Embeddable::ImageQuestion do
  it_behaves_like "a question"

  let (:image_question) { FactoryGirl.create(:image_question) }

  it "should create a new instance with default values" do
    expect(image_question).to be_valid
  end

  describe '#to_hash' do
    it 'has interesting attributes' do
      expected = {
        name: image_question.name,
        prompt: image_question.prompt,
        drawing_prompt: image_question.drawing_prompt,
        bg_source: image_question.bg_source,
        bg_url: image_question.bg_url,
        is_prediction: image_question.is_prediction,
        give_prediction_feedback: image_question.give_prediction_feedback,
        prediction_feedback: image_question.prediction_feedback,
        is_hidden: image_question.is_hidden
      }
      expect(image_question.to_hash).to eq(expected)
    end
  end

  describe "export" do
    let(:json){ emb.export.as_json }
    let(:emb) { image_question }
    it 'preserves is_hidden' do
      emb.is_hidden = true
      expect(json['is_hidden']).to eq true
    end
  end

  describe '#duplicate' do
    it 'returns a new instance with copied attributes' do
      expect(image_question.duplicate).to be_a_new(Embeddable::ImageQuestion).with( name: image_question.name, prompt: image_question.prompt, drawing_prompt: image_question.drawing_prompt, bg_source: image_question.bg_source, bg_url: image_question.bg_url )
    end
  end

  describe '#is_shutterbug?' do
    it 'returns true if bg_source is Shutterbug' do
      expect(image_question.is_shutterbug?).to be_truthy
    end

    it 'returns false otherwise' do
      image_question.bg_source = 'Drawing'
      expect(image_question.is_shutterbug?).to be_falsey
    end
  end

  describe '#is_drawing?' do
    it 'returns true if bg_source is Drawing' do
      image_question.bg_source = 'Drawing'
      expect(image_question.is_drawing?).to be_truthy
    end

    it 'returns false otherwise' do
      expect(image_question.is_drawing?).to be_falsey
    end
  end

  describe "import" do
    let(:json_with_promt){ image_question.export.as_json.symbolize_keys }
    let(:json_without_promt){ 
      img_ques = image_question.export.as_json.symbolize_keys
      img_ques.except(:prompt)
    }
    it "does not reset the default prompt if there is prompt in the json" do
      new_image_question = Embeddable::ImageQuestion.import(json_with_promt)
      expect(new_image_question.prompt).to eq(image_question.prompt)
    end
    it "resets the default prompt if there is no prompt in the json" do
      new_image_question = Embeddable::ImageQuestion.import(json_without_promt)
      expect(new_image_question.prompt).to eq("")
    end
  end
end
