require 'spec_helper'

feature "Upload figures", js: true do
  let(:author) { FactoryGirl.create :user }
  let(:paper) { author.papers.create! short_title: 'foo bar', journal: Journal.create! }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author.email
  end

  scenario "Author uploads figures" do
    edit_paper = EditPaperPage.visit paper

    edit_paper.view_card 'Upload Figures' do |overlay|
      overlay.attach_figure
      expect(overlay).to have_image 'yeti.tiff'
      overlay.mark_as_complete
      expect(overlay).to be_completed
    end

    edit_paper.reload

    edit_paper.view_card 'Upload Figures' do |overlay|
      expect(overlay).to have_image('yeti.tiff')
      expect(overlay).to be_completed
    end
  end

  scenario "Author destroys figure immediately" do
    edit_paper = EditPaperPage.visit paper
    edit_paper.view_card 'Upload Figures' do |overlay|
      overlay.attach_figure
      find('.figure-container').hover
      find('.glyphicon-trash').click
      expect(overlay).to_not have_selector('.figure-image')
    end
  end

  scenario "Author destroys figure after page reload" do
    edit_paper = EditPaperPage.visit paper
    edit_paper.view_card 'Upload Figures' do |overlay|
      overlay.attach_figure
    end

    edit_paper.reload

    edit_paper.view_card 'Upload Figures' do |overlay|
      find('.figure-container').hover
      find('.glyphicon-trash').click
      expect(overlay).to_not have_selector('.figure-image')
    end
  end
end
