# After a resubmission, we need to generate a new
# reviewer report for any existing review tasks
class Paper::Submitted::CreateReviewerReports
  REVIEWER_SPECIFIC_TASKS = ["TahiStandardTasks::FrontMatterReviewerReportTask",
                             "TahiStandardTasks::ReviewerReportTask"].freeze

  def self.call(_, event_data)
    paper = event_data[:record]

    reviewer_tasks = paper.tasks.where(type: REVIEWER_SPECIFIC_TASKS)
    reviewer_tasks.each do |task|
      report = ReviewerReport.find_or_initialize_by(
        task: task,
        decision: paper.draft_decision,
        user: task.reviewer
      )

      # assign latest card version if one is not already set
      card_version = report.card_version || latest_published_card_version(paper)
      report.card_version = card_version

      report.save!
    end
  end

  def self.latest_published_card_version(paper)
    klass = if paper.uses_research_article_reviewer_report
              "ReviewerReport"
            else
              # note: this AR model does not yet exist, but
              # is being done as preparatory / consistency for
              # card config work
              "TahiStandardTasks::FrontMatterReviewerReport"
            end

    # since a FrontMatterReviewerReport is not yet an actual ActiveRecord
    # object, purposely not doing `klass.latest_published_card_version` here.
    Card.find_by_class_name(klass).latest_published_card_version
  end
end
