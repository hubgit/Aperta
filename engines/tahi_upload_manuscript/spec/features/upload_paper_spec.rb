require 'rails_helper'

feature "Upload paper", js: true, selenium: true do
  let(:author) { FactoryGirl.create :user }
  let!(:paper) do
    FactoryGirl.create :paper_with_task,
      creator: author,
      task_params: {
        title: "Upload Manuscript",
        type: "TahiUploadManuscript::UploadManuscriptTask",
        role: "author"
      }
  end

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author
  end

  scenario "Author uploads paper in Word format" do
    expect(DownloadManuscriptWorker).to receive(:perform_async) do |manuscript_id, url|
      paper.manuscript.update(status: "done")
      paper.update(title: "This is a Title About Turtles", body: "And this is my subtitle")
    end

    click_link paper.reload.title
    edit_paper_page = EditPaperPage.new
    edit_paper_page.view_card('Upload Manuscript').upload_word_doc

    expect(page).to have_no_css('.overlay.in')
    expect(edit_paper_page).to have_paper_title("This is a Title About Turtles")
    expect(edit_paper_page).to have_body_text("And this is my subtitle")
    edit_paper_page.view_card 'Upload Manuscript' do |card|
      expect(card.completed_checkbox).to be_checked
    end
  end
end
