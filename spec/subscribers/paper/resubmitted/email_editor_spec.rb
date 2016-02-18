require 'rails_helper'

describe Paper::Resubmitted::EmailEditor do
  include EventStreamMatchers

  let(:mailer) { mock_delayed_class(UserMailer) }
  let!(:paper) { FactoryGirl.create(:paper, :with_academic_editor_user) }
  let!(:user) { FactoryGirl.create(:user) }

  before { assign_paper_role(paper, user, PaperRole::EDITOR) }

  it "sends an email to the editor" do
    expect(mailer).to receive(:notify_editor_of_paper_resubmission).with(paper.id)
    described_class.call("tahi:paper:resubmitted", { record: paper })
  end

end
