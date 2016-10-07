# Serves as the API for invitations
class InvitationsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    invitations = current_user.invitations_from_latest_revision
    respond_with(invitations, each_serializer: InvitationIndexSerializer)
  end

  def show
    fail AuthorizationError unless invitation.can_be_viewed_by?(current_user)
    respond_with invitation
  end

  def update
    requires_user_can(:manage_invitations, invitation.task)
    invitation.update_attributes(invitation_update_params)
    respond_with invitation
  end

  def destroy
    requires_user_can(:manage_invitations, invitation.task)
    unless invitation.pending?
      invitation.errors.add(
        :invited,
        "This invitation has been sent and must be rescinded."
      )
      fail ActiveRecord::RecordInvalid, invitation
    end

    invitation.destroy!

    respond_with invitation
  end

  def send_invite
    requires_user_can(:manage_invitations, invitation.task)
    send_and_notify(invitation)
    render json: invitation
  end

  def create
    requires_user_can(:manage_invitations, task)
    invitation = task.invitations.build(
      invitation_params.merge(inviter: current_user)
    )
    if invitation_params[:state] == 'pending'
      invitation.set_invitee
      invitation.save
    else
      send_and_notify(invitation)
    end
    respond_with(invitation)
  end

  def rescind
    task = invitation.task
    requires_user_can(:manage_invitations, task)
    invitation.rescind!
    Activity.invitation_withdrawn!(invitation, user: current_user)
    render json: invitation
  end

  def accept
    fail AuthorizationError unless invitation.invitee == current_user
    invitation.actor = current_user
    invitation.accept!
    Activity.invitation_accepted!(invitation, user: current_user)
    render json: invitation
  end

  def decline
    fail AuthorizationError unless invitation.invitee == current_user
    invitation.update_attributes(
      actor: current_user,
      decline_reason: invitation_params[:decline_reason],
      reviewer_suggestions: invitation_params[:reviewer_suggestions]
    )
    invitation.decline!
    Activity.invitation_declined!(invitation, user: current_user)
    render json: invitation
  end

  private

  def send_and_notify(invitation)
    invitation.invite!
    Activity.invitation_sent!(invitation, user: current_user)
  end

  def invitation_params
    params
      .require(:invitation)
      .permit(:actor_id,
        :body,
        :decline_reason,
        :decision_id,
        :email,
        :state,
        :reviewer_suggestions,
        :task_id,
        :primary_id,
        :position,
        :invite_queue_id)
  end

  def invitation_update_params
    params
      .require(:invitation)
      .permit(:body, :email, :primary_id, :queue_id)
  end

  def task
    @task ||= Task.find(params[:invitation][:task_id])
  end

  def invitation
    @invitation ||= Invitation.find(params[:id])
  end
end
