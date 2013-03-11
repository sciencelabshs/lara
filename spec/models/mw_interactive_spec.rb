require 'spec_helper'

describe MwInteractive do
  let (:interactive) { FactoryGirl.create(:mw_interactive) }
  let (:page) { FactoryGirl.create(:page) }

  it 'has valid attributes' do
    interactive.valid?
  end

  it 'can to associate an interactive page' do
    
    page.add_interactive(interactive)

    interactive.reload
    page.reload

    interactive.interactive_page.should == page
  end

  it 'returns an aspect ratio based on native height and native width' do
    interactive.aspect_ratio.should === 1.3241379310344827
    interactive.native_width = 500
    interactive.native_height = 250
    interactive.save
    interactive.aspect_ratio.should === 2
  end

  it 'returns a calculated height from a supplied width, based on aspect ratio' do
    interactive.height(800).should === 604.1666666666666
  end
end
