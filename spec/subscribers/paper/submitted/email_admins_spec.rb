require 'rails_helper'

describe Paper::Submitted::EmailAdmins do
  include EventStreamMatchers

  let(:mailer) { mock_delayed_class(UserMailer) }
  let!(:paper) { instance_double(Paper, id: 99, admins: []) }
  let!(:user) { FactoryGirl.build_stubbed(:user) }

  it "sends an email to each admin" do
    expect(paper).to receive(:admins).and_return [user]
    expect(mailer).to receive(:notify_admin_of_paper_submission).with(paper.id, user.id)
    described_class.call("tahi:paper:submitted", { record: paper })
  end

end
