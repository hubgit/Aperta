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

# Serves as the API for invitations
class InvitationsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    invitations = current_user.invitations_from_draft_decision
    respond_with(invitations, each_serializer: InvitationIndexSerializer)
  end

  def show
    requires_user_can_view(invitation)
    respond_with invitation
  end

  def update
    requires_user_can(:manage_invitations, invitation.task)
    invitation.update_attributes!(invitation_update_params)
    head :no_content
  end

  # non restful route for drag and drop changes
  def update_position
    requires_user_can(:manage_invitations, invitation.task)
    invitation.invitation_queue.move_invitation_to_position(
      invitation, params[:position]
    )

    render json: invitations_in_queue
  end

  # non restful route for assigning and unassigning primaries
  def update_primary
    requires_user_can(:manage_invitations, invitation.task)
    if params[:primary_id].present?
      new_primary = Invitation.find(params[:primary_id])
      invitation.invitation_queue.assign_primary(
        primary: new_primary,
        invitation: invitation
      )
    else
      invitation.invitation_queue.unassign_primary_from(invitation)
    end

    render json: invitations_in_queue
  end

  def destroy
    requires_user_can(:manage_invitations, invitation.task)
    unless invitation.pending?
      invitation.errors.add(
        :invited,
        "This invitation has been sent and must be rescinded."
      )
      raise ActiveRecord::RecordInvalid, invitation
    end

    queue = invitation.invitation_queue
    queue.destroy_invitation(invitation)

    render json: invitations_in_queue(queue)
  end

  def send_invite
    requires_user_can(:manage_invitations, invitation.task)
    send_and_notify(invitation)
    render json: invitations_in_queue
  end

  def create
    requires_user_can(:manage_invitations, task)
    @invitation = task.invitations.build(
      invitation_create_params.merge(inviter: current_user)
    )
    invitation_queue = task.active_invitation_queue
    invitation_queue.add_invitation(invitation)

    @invitation.set_invitee
    @invitation.set_body

    @invitation.save!

    render json: invitations_in_queue
  end

  def rescind
    task = invitation.task
    requires_user_can(:manage_invitations, task)
    invitation.rescind!
    Activity.invitation_withdrawn!(invitation, user: current_user)
    render json: invitation
  end

  def accept
    requires_user_can(:manage_invitations, invitation.task) unless invitation.invitee == current_user
    invitee = find_or_create_invitee
    validate_invitee(invitee)
    invitation.reload # refresh invitation data bc user creation callbacks
    invitation.actor = current_user
    invitation.accept!
    Activity.invitation_accepted!(invitation, user: current_user)
    render json: invitation
  end

  def decline
    raise AuthorizationError unless invitation.invitee == current_user
    invitation.update_attributes(
      invitation_decline_params.merge(actor: current_user)
    )
    invitation.decline!
    Activity.invitation_declined!(invitation, user: current_user)
    render json: invitation
  end

  private

  def invitations_in_queue(queue = nil)
    invitations = if queue
                    queue.invitations
                  else
                    invitation.invitation_queue.invitations
                  end

    invitations
      .reorder(id: :desc)
      .includes(
        :task,
        :invitee,
        :primary,
        :alternates,
        :invitation_queue,
        :attachments)
  end

  def send_and_notify(invitation)
    invitation.invitation_queue.send_invitation(invitation)
    Activity.invitation_sent!(invitation, user: current_user)
  end

  def invitation_create_params
    params
      .require(:invitation)
      .permit(:actor_id,
        :decline_reason,
        :decision_id,
        :email,
        :state,
        :reviewer_suggestions,
        :task_id,
        :due_in)
  end

  def invitation_update_params
    attr_list = [:body, :email]
    attr_list << :due_in if params.dig(:invitation, :due_in)
    params
      .require(:invitation)
      .permit(attr_list)
  end

  def invitation_decline_params
    params
      .require(:invitation)
      .permit(:decline_reason, :reviewer_suggestions)
  end

  def invitation_accept_params
    params.permit(:first_name, :last_name)
  end

  def task
    @task ||= Task.find(params[:invitation][:task_id])
  end

  def invitation
    @invitation ||= Invitation.find(params[:id])
  end

  def find_or_create_invitee
    invitation.invitee || User.create(invitation_accept_params) do |user|
      user.email = invitation.email
      user.auto_generate_password
      user.auto_generate_username
    end
  end

  def validate_invitee(invitee)
    return if invitee.valid?
    invitation.errors.add(:invitee, 'User creation error')
    raise ActiveRecord::RecordInvalid, invitation
  end
end
