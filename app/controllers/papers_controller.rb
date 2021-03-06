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

# Papers Controller
class PapersController < ApplicationController
  before_action :authenticate_user!

  rescue_from AASM::InvalidTransition, with: :render_invalid_transition_error

  respond_to :json

  def index
    papers = current_user.filter_authorized(
      :view,
      Paper.all.includes(:file, :export_deliveries, :roles, journal: :creator_role)
    ).objects
    active_papers, inactive_papers = papers.partition(&:active?)
    respond_with(papers, each_serializer: LitePaperSerializer,
                         meta: { total_active_papers: active_papers.length,
                                 total_inactive_papers:
                                 inactive_papers.length })
  end

  def show
    paper = Paper.eager_load(
      :supporting_information_files,
      :journal
    ).find_by_id_or_short_doi(params[:id])

    if current_user.unaccepted_and_invited_to?(paper: paper)
      return render status: :forbidden, text: 'To access this manuscript, ' \
          'please accept the invitation below.'
    end

    requires_user_can_view(paper, not_found: true)
    respond_with(paper)
  end

  # The create action does not require a permission, it's available to any
  # signed in user.
  def create
    raise AuthorizationError if FeatureFlag['DISABLE_SUBMISSIONS']
    paper = PaperFactory.create(paper_params, current_user)
    if paper.valid?
      Activity.paper_created!(paper, user: current_user) if paper.valid?

      url = params.dig(:paper, :url)
      if url
        DownloadManuscriptWorker.download(
          paper,
          url,
          current_user
        )
      end
    end
    respond_with paper
  end

  def update
    requires_user_can(:edit, paper)
    unless paper.editable?
      paper.errors.add(:editable, "This paper is currently locked for review.")
      raise ActiveRecord::RecordInvalid, paper
    end

    paper.update(update_paper_params)
    Activity.paper_edited!(paper, user: current_user)

    respond_with paper
  end

  ## SUPPLEMENTAL INFORMATION
  def comment_looks
    requires_user_can(:view, paper)
    comment_looks = paper.comment_looks.where(user: current_user)
    .includes(:task)
    respond_with(comment_looks, root: :comment_looks)
  end

  def versioned_texts
    requires_user_can(:view, paper)
    versions = paper.versioned_texts
      .includes(:submitting_user)
      .order('major_version DESC, minor_version DESC')
    respond_with versions, each_serializer: VersionedTextSerializer,
                           root: 'versioned_texts'
  end

  def workflow_activities
    requires_user_can(:manage_workflow, paper)
    activities = Activity.includes(:user).for_paper_workflow(paper)
    respond_with activities, each_serializer: ActivitySerializer, root: 'feeds'
  end

  def manuscript_activities
    requires_user_can(:view_recent_activity, paper)
    activities = Activity.includes(:user).feed_for('manuscript', paper)
    respond_with activities, each_serializer: ActivitySerializer, root: 'feeds'
  end

  def snapshots
    requires_user_can(:view, paper)
    snapshots = paper.snapshots
    respond_with snapshots,
                 each_serializer: SnapshotSerializer,
                 root: 'snapshots'
  end

  def related_articles
    requires_user_can(:edit_related_articles, paper)
    respond_with paper.related_articles,
                 each_serializer: RelatedArticleSerializer,
                 root: 'related_articles'
  end

  ## EDITING

  def toggle_editable
    requires_user_can(:manage_workflow, paper)
    paper.toggle!(:editable)
    status = paper.valid? ? 200 : 422
    Activity.editable_toggled!(paper, user: current_user)
    render json: paper, status: status
  end

  ## STATE CHANGES
  def submit
    requires_user_can(:submit, paper)
    Paper.transaction do
      if paper.gradual_engagement? && paper.unsubmitted?
        paper.initial_submit! current_user
        Activity.paper_initially_submitted! paper, user: current_user
      elsif paper.checking?
        paper.submit_minor_check! current_user
      else
        paper.submit! current_user
        Activity.paper_submitted! paper, user: current_user
      end
    end
    render json: paper, status: :ok
  end

  def reactivate
    requires_user_can(:reactivate, paper)
    paper.reactivate!
    Activity.paper_reactivated! paper, user: current_user
    render json: paper, status: :ok
  end

  def withdraw
    requires_user_can :withdraw, paper
    paper.withdraw! withdrawal_params[:reason], current_user
    UserMailer.delay.notify_staff_of_paper_withdrawal(@paper.id)
    Activity.paper_withdrawn! paper, user: current_user
    render json: paper, status: :ok
  end

  private

  def render_invalid_transition_error(e)
    render status: 422, json:
    { errors: ["Failure to transition to #{e.event_name}"] }
  end

  def withdrawal_params
    params.permit(:reason)
  end

  def paper_params
    params.require(:paper).permit(
      :title, :abstract,
      :body, :paper_type, :submitted, :editable,
      :journal_id,
      reviewer_ids: [],
      phase_ids: [],
      assignee_ids: [],
      editor_ids: [],
      figure_ids: []
    )
  end

  def update_paper_params
    # paper params excluding :submitted and :editable
    params.require(:paper).permit(
      :title, :abstract,
      :paper_type,
      :journal_id,
      reviewer_ids: [],
      phase_ids: [],
      assignee_ids: [],
      editor_ids: [],
      figure_ids: []
    )
  end

  def paper
    @paper ||= Paper.find_by_id_or_short_doi(params[:id])
  end
end
