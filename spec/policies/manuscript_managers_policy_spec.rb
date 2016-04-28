require 'rails_helper'

describe ManuscriptManagersPolicy do
  include AuthorizationSpecHelper

  let(:policy) { ManuscriptManagersPolicy.new(current_user: user, paper: paper) }

  before(:all) do
    clear_roles_and_permissions
    @journal = JournalFactory.create(name: 'Genetics Journal')
  end

  after(:all) do
    clear_roles_and_permissions
    @journal.destroy!
  end

  let(:journal) { @journal }

  context "admin" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }
    let(:paper) { FactoryGirl.create(:paper, journal: journal) }

    it { expect(policy.show?).to be(true) }
    it { expect(policy.can_manage_manuscript?).to be(true) }
  end

  context "non admin" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper, journal: journal) }

    it { expect(policy.show?).to be(false) }
    it { expect(policy.can_manage_manuscript?).to be(false) }
  end

  context "user with manuscript manager old_role who is assigned to the paper" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) do
      FactoryGirl.create(:paper, :with_tasks, journal: journal)
    end
    let(:old_role) { FactoryGirl.create(:old_role, journal: paper.journal, can_view_assigned_manuscript_managers: true) }

    before do
      old_role.update_attribute :can_view_assigned_manuscript_managers, true
      assign_journal_role(paper.journal, user, old_role)
      paper.paper_roles.create!(old_role: PaperRole::EDITOR, user: user)
      paper.reload
    end

    it { expect(policy.show?).to be(true) }
    it { expect(policy.can_manage_manuscript?).to be(true) }
  end

  context "user with manuscript manager old_role who is not assigned to a paper task" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) do
      FactoryGirl.create(:paper, :with_tasks, journal: journal)
    end
    let(:old_role) { FactoryGirl.create(:old_role, journal: paper.journal, can_view_assigned_manuscript_managers: true) }

    before do
      assign_journal_role(paper.journal, user, old_role)
    end

    it { expect(policy.show?).to be(false) }
    it { expect(policy.can_manage_manuscript?).to be(false) }
  end

  context "user with all manuscript managers old_role" do
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper, journal: journal) }
    let(:old_role) { FactoryGirl.create(:old_role, journal: paper.journal, can_view_all_manuscript_managers: true) }

    before do
      assign_journal_role(paper.journal, user, old_role.kind)
    end

    it { expect(policy.show?).to be(true) }
    it { expect(policy.can_manage_manuscript?).to be(true) }
  end
end
