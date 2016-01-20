require 'securerandom'

FactoryGirl.define do
  factory :paper do
    after(:create) do |paper|
      paper.save!
      paper.body = "I am the very model of a modern journal article"
    end

    journal
    creator factory: User

    sequence :title do |n|
      "Feature Recognition from 2D Hints in Extruded Solids - #{n}-#{SecureRandom.hex(3)}"
    end

    trait(:active) do
      publishing_state "unsubmitted"
      active true
    end

    trait(:inactive) do
      publishing_state "withdrawn"
      active false
    end

    # TODO: find all cases where this trait is used and change to trait of 'submitted'
    trait(:completed) do
      publishing_state "submitted"
    end

    trait(:initially_submitted) do
      publishing_state 'initially_submitted'
      editable = false
    end

    trait(:submitted) do
      after(:create) do |paper|
        paper.submit! paper.creator
      end
    end

    trait(:unsubmitted) do
      publishing_state "unsubmitted"
      editable = true
    end

    trait(:with_tasks) do
      after(:create) do |paper|
        PaperFactory.new(paper, paper.creator).add_phases_and_tasks
      end
    end

    trait(:with_short_title) do
      # Paper#short title is stored in a NestedQuestionAnswer; so ya
      # better build one.
      transient do
        short_title ''
      end

      after(:create) do |paper, evaluator|
        task = FactoryGirl.create(
          :publishing_related_questions_task,
          paper: paper)
        question = NestedQuestion.find_by(
          ident: 'publishing_related_questions--short_title')
        FactoryGirl.create(
          :nested_question_answer,
          paper: paper,
          value: evaluator.short_title,
          nested_question: question,
          owner: task)
      end
    end

    trait(:with_valid_author) do
      after(:create) do |paper|
        FactoryGirl.create(
          :author,
          paper: paper,
          authors_task: paper.tasks.find_by(type: "TahiStandardTasks::AuthorsTask")
        )
      end
    end

    trait(:with_editor) do
      after(:create) do |paper|
        editor = FactoryGirl.build(:user)
        FactoryGirl.create(:paper_role, :editor, paper: paper, user: editor)
      end
    end

    trait(:with_versions) do
      transient do
        first_version_body  'first body'
        second_version_body 'second body'
      end

      after(:create) do |paper, evaluator|
        paper.body = evaluator.first_version_body
        paper.save!

        paper.submit! paper.creator
        paper.major_revision!
        paper.body = evaluator.second_version_body
        paper.save!
      end
    end

    after(:build) do |paper|
      paper.paper_type ||= paper.journal.paper_types.first
    end

    after(:create) do |paper, evaluator|
      paper.paper_roles.create!(user: paper.creator, old_role: PaperRole::COLLABORATOR)
      Role.ensure_exists('Author', participates_in: [Task]) do |role|
        role.ensure_permission_exists(:view, applies_to: 'Task')
        role.ensure_permission_exists(:view, applies_to: 'Paper')
      end
      DefaultAuthorCreator.new(paper, paper.creator).create!
      paper.decisions.create!

      paper.body = evaluator.body
    end

    factory :paper_with_phases do
      transient do
        phases_count 1
      end

      after(:create) do |paper, evaluator|
        paper.phases << FactoryGirl.build_list(:phase, evaluator.phases_count)
      end
    end

    factory :paper_with_task do
      transient do
        task_params {}
      end

      after(:create) do |paper, evaluator|
        phase = create(:phase, paper: paper)
        evaluator.task_params[:title] ||= "Ad Hoc"
        evaluator.task_params[:old_role] ||= "user"
        evaluator.task_params[:type] ||= "Task"
        evaluator.task_params[:paper] ||= paper

        phase.tasks.create(evaluator.task_params)
        paper.reload
      end
    end

    factory :paper_ready_for_export do
      doi "blah/yetijour.123334"

      after(:create) do |paper|
        editor = FactoryGirl.build(:user)
        FactoryGirl.create(:paper_role, :editor, paper: paper, user: editor)

        phase = create(:phase, paper: paper)

        # Authors
        authors_task = FactoryGirl.create(:authors_task, paper: paper),
        author = FactoryGirl.create(:author, paper: paper, authors_task: authors_task)
        NestedQuestionableFactory.create(
          author,
          questions: [
            {
              ident: 'other',
              answer: 'footstool',
              value_type: 'text'
            },
            {
              ident: 'desceased',
              answer: false,
              value_type: 'boolean'
            },
            {
              ident: 'published_as_corresponding_author',
              answer: true,
              value_type: 'boolean'
            },
            {
              ident: 'contributions',
              answer: true,
              value_type: 'boolean',
              questions: [
                {
                  ident: 'made_cookie_dough',
                  answer: true,
                  value_type: 'boolean'
                }
              ]
            }
          ]
        )

        # Financial Disclosure
        financial_task = create(:financial_disclosure_task, funders: [], paper: paper)
        NestedQuestionableFactory.create(
          financial_task,
          questions: [
            {
              ident: 'author_received_funding',
              answer: false,
              value_type: 'boolean'
            }
          ]
        )

        # Competing interests
        NestedQuestionableFactory.create(
          FactoryGirl.create(:competing_interests_task, paper: paper),
          questions: [
            {
              ident: 'competing_interests',
              answer: 'true',
              value_type: 'boolean',
              questions: [
                {
                  ident: 'statement',
                  answer: 'entered statement',
                  value_type: 'text'
                }
              ]
            }
          ]
        )

        # data availability
        NestedQuestionableFactory.create(
          FactoryGirl.create(:data_availability_task, paper: paper),
          questions: [
            {
              ident: 'data_fully_available',
              answer: 'true',
              value_type: 'boolean'
            },
            {
              ident: 'data_location',
              answer: 'holodeck',
              value_type: 'text'
            }
          ]
        )

        NestedQuestionableFactory.create(
          FactoryGirl.create(:production_metadata_task, paper: paper),
          questions: [
            {
              ident: 'publication_date',
              answer: '12/15/2025',
              value_type: 'text'
            }
          ]
        )

        version = paper.latest_version
        version.source = File.open(Rails.root.join('spec/fixtures/about_turtles.docx'))
        version.save!
        paper.save!

        paper.reload
      end
    end
  end
end
