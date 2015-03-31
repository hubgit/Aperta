module PlosAuthors
  class PlosAuthorsTask < Task

    register_task default_title: "Add Authors", default_role: "author"

    include MetadataTask

    has_many :plos_authors, inverse_of: :plos_authors_task

    validates_with AssociationValidator, association: :plos_authors, fail: :set_completion_error, if: :completed?
    validate :corresponding_plos_authors, if: :completed?

    def active_model_serializer
      PlosAuthorsTaskSerializer
    end

    def convert_generic_authors!
      transaction do
        self.incomplete! if paper.authors.generic.any?
        paper.authors.generic.each do |author|
          PlosAuthor.create!(author: author, plos_authors_task: self)
        end
      end
    end

    private

    def corresponding_plos_authors
      return true if plos_authors.where(corresponding: true).exists?
      self.errors.add(:corresponding, "You must have at least one corresponding author.")
    end

    def set_completion_error
      self.errors.add(:completed, "Please fix validation errors above.")
    end
  end
end
