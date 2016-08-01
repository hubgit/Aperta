require 'rails_helper'

describe TahiStandardTasks::RegisterDecisionTask do
  let(:journal) do
    FactoryGirl.create(
      :journal,
      :with_academic_editor_role,
      :with_creator_role,
      :with_task_participant_role,
      name: 'PLOS Yeti'
    )
  end
  let!(:paper) do
    FactoryGirl.create(
      :paper_with_phases,
      :with_creator,
      :submitted_lite,
      journal: journal,
      title: 'Crazy stubbing tests on rats'
    )
  end
  let!(:task) do
    TahiStandardTasks::RegisterDecisionTask.create!(
      title: "Register Decision",
      old_role: "editor",
      paper: paper,
      phase: paper.phases.first
    )
  end

  describe '.restore_defaults' do
    include_examples '<Task class>.restore_defaults update title to the default'
    include_examples '<Task class>.restore_defaults update old_role to the default'
  end

  describe "save and retrieve paper decision and decision letter" do
    let(:paper) do
      FactoryGirl.create(
        :paper,
        :with_integration_journal,
        :with_creator,
        :with_tasks,
        title: "Crazy stubbing tests on rats",
        decision_letter: "Lorem Ipsum"
      )
    end

    let(:decision) {
      paper.decisions.first
    }

    let(:task) {
      TahiStandardTasks::RegisterDecisionTask.create(
        title: "Register Decision",
        old_role: "editor",
        phase: paper.phases.first)
    }

    before do
      allow(task).to receive(:paper).and_return(paper)
    end

    describe "#paper_decision_letter" do
      it "returns paper's decision" do
        expect(task.paper_decision_letter).to eq("Lorem Ipsum")
      end
    end

    describe "#paper_decision_letter=" do
      it "returns paper's decision" do
        task.paper_decision_letter = "Rejecting because I can"
        expect(task.paper_decision_letter).to eq("Rejecting because I can")
      end
    end
  end

  describe "#after_register" do
    let(:decision) { paper.draft_decision }

    before do
      paper.update(publishing_state: :submitted)
      task.reload
    end

    context "decision is a revision" do
      before do
        allow(decision).to receive(:revision?).and_return(true)
      end

      it "invokes DecisionReviser" do
        expect(TahiStandardTasks::ReviseTask)
          .to receive(:setup_new_revision).with(task.paper, task.phase)
        task.after_register decision
      end
    end

    it "sends an email to the author" do
      expect(TahiStandardTasks::RegisterDecisionMailer)
        .to receive_message_chain(:delay, :notify_author_email)
        .with(decision_id: decision.id)
      task.after_register decision
    end
  end

  describe "#after_update" do
    before do
      allow_any_instance_of(Decision).to receive(:revision?).and_return(true)
      task.paper.draft_decision.update_attribute(:verdict, 'major_revision')
    end

    context "when the decision is 'Major Revision' and task is incomplete" do
      it "does not create a new task for the paper" do
        expect {
          task.save!
        }.to_not change { task.paper.tasks.size }
      end
    end

    context "when the decision is 'Major Revision' and task is completed" do
      let(:revise_task) do
        task.paper.tasks.detect do |paper_task|
          paper_task.type == "TahiStandardTasks::ReviseTask"
        end
      end

      before do
        task.save!
        task.update_attributes completed: true
        task.after_update
      end

      it "task has no participants" do
        expect(task.participants).to be_empty
      end

      it "task participants does not include author" do
        expect(task.participants).to_not include paper.creator
      end
    end
  end
end
