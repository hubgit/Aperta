require "rails_helper"

describe Snapshot::CoverLetterTaskSerializer do
  subject(:serializer) { described_class.new(task) }
  let(:task) { FactoryGirl.create(:cover_letter_task) }

  describe "#as_json" do
    it "serializes to JSON" do
      expect(serializer.as_json).to include(
        name: "cover-letter-task",
        type: "properties"
      )
    end

    it_behaves_like "snapshot serializes related answers as nested questions", resource: :task
  end
end
