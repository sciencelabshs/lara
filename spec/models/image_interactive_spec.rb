require 'spec_helper'

describe ImageInteractive do
  let(:image_interactive) { FactoryGirl.create(:image_interactive) }
  let(:page) { FactoryGirl.create(:page) }

  it 'has valid attributes' do
    image_interactive.valid?
  end

  it 'can to associate an interactive page' do
    page.add_interactive(image_interactive)

    image_interactive.reload
    page.reload

    image_interactive.interactive_page.should == page
  end

  describe '#to_hash' do
    it 'has useful values' do
      expected = { url: image_interactive.url, caption: image_interactive.caption, credit: image_interactive.credit, credit_url: image_interactive.credit_url}
      image_interactive.to_hash.should == expected
    end
  end

  describe '#duplicate' do
    it 'is a new instance of ImageInteractive with values' do
      image_interactive.duplicate.should be_a_new(ImageInteractive).with( url: image_interactive.url, caption: image_interactive.caption, credit: image_interactive.credit )
    end
  end

  describe "#credit_with_link" do
    let(:credit)     { nil }
    let(:credit_url) { nil }
    let(:parms)      { {:credit => credit, :credit_url => credit_url } }
    let(:link)       { ImageInteractive.new(parms).credit_with_link  } 
    describe "With nil values" do
      it "should return an empty string" do
        link.should be_blank
      end
    end
    describe "with credit but no credit_url" do
      let(:credit) {"some text"}
      it "should return 'some text'" do
        link.should ==  "some text"
      end
    end
    describe "with a credit url and text" do
      let(:credit)        { "some text" }
      let(:credit_url)    { "http://amazon.com" }
      let(:expected_link) { "<a href='http://amazon.com' target='_blank'>some text</a>" }
      it "should return an link to amazon.com" do
        link.should == expected_link
      end
    end
  end
end
