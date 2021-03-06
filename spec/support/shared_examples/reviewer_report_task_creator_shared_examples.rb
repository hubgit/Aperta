# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

RSpec.shared_examples_for 'creating a reviewer report task' do |reviewer_report_type:|

  before do
    FactoryGirl.create :review_duration_period_setting_template
  end
  context "assigning reviewer old_role" do
    context "with no existing reviewer" do
      it "creates a ReviewerReportTask" do
        expect {
          subject.process
        }.to change { reviewer_report_type.count }.by(1)
      end

      it 'creates new assignments' do
        expect { subject.process }.to change { Assignment.count }.by(2)
      end

      it 'assigns the user as a Participant on the Paper' do
        subject.process
        expect(
          Assignment.find_by(
            user: assignee,
            role: paper.journal.reviewer_role,
            assigned_to: paper
          )
        ).to be
      end

      it 'assigns the user as a Reviewer Report Owner on the task' do
        subject.process
        task = reviewer_report_type.last
        expect(
          Assignment.find_by(
            user: assignee,
            role: paper.journal.reviewer_report_owner_role,
            assigned_to: task
          )
        ).to be
      end
    end

    context "with an existing reviewer" do
      before do
        FactoryGirl.create(:user).tap do |reviewer|
          reviewer.assignments.create!(
            assigned_to: originating_task,
            role: paper.journal.reviewer_role
          )
        end
      end

      it "creates a #{reviewer_report_type}" do
        expect {
          subject.process
        }.to change { reviewer_report_type.count }.by(1)
      end
    end
  end

  context "with existing #{reviewer_report_type} for User" do
    context "if the user has no preexisting roles" do
      before do
        assignee.roles.destroy_all
      end

      it "does not include the user as a participant to the task" do
        subject.process
        task = paper.tasks_for_type(reviewer_report_type.name).first
        expect(task.participants).not_to include(assignee)
      end
    end

    it "uncompletes and unsubmits the task" do
      ReviewerReportTaskCreator.new(
        originating_task: originating_task,
        assignee_id: assignee.id
      ).process
      expect(reviewer_report_type.count).to eq 1
      expect(reviewer_report_type.first.completed).to eq false
      expect(reviewer_report_type.first.submitted?).to eq false
    end
  end

  it "does not add the reviewer as a participant on the task" do
    subject.process
    task = paper.tasks_for_type(reviewer_report_type.name).first
    expect(task.participants).not_to include(assignee)
  end

  context 'when assigning a new reviewer' do
    it 'sends the welcome email' do
      expect(TahiStandardTasks::ReviewerMailer).to \
        receive_message_chain('delay.welcome_reviewer')
      subject.process
    end
  end

  FeatureFlag.destroy_all
end
