require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::ExternalScript do
  let (:props)  { {} }
  let (:script) { Embeddable::ExternalScript.create(props) }

  let (:page) do
    p = FactoryGirl.create(:interactive_page)
  end

  # address bug:  undefined method `is_hidden?'
  describe '#is_hidden?' do
    it "should be a method returning false" do
      expect(script).to respond_to(:is_hidden?)
      expect(script.is_hidden?).to eq(false)
    end
  end

  describe '#page_section'  do

    describe 'when the embeddable is not in a page' do
      it "the section should be false" do
        expect(script.page_section).to eql(false)
      end
    end

    describe 'When the embeddable is added to a page' do
      let(:section) { nil }
      before(:each) do
        page.add_embeddable(script,0, section)
        page.reload
        script.reload
      end

      describe 'when there is no section' do
        it "the page_section should be returned as nil" do
          expect(script.reload.page_section).to eql(nil)
        end
        describe 'the page export' do
          it "should include an ebmeddables section" do
            expect(page.export).to include(:embeddables)
          end
        end
      end

      describe 'when the embeddable is added to the C-RATER section' do
        let(:section) { CRater::ARG_SECTION_NAME }
        it "The section should be returned as CRater::ARG_SECTION_NAME" do
          expect(script.reload.page_section).to eql(CRater::ARG_SECTION_NAME)
        end

        describe 'the page export' do
          it "should include an ebmeddables section" do
            expect(page.export).to include(:embeddables)
          end
        end
      end

    end
  end


end
