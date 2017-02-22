# CARD_CONFIG
# This is a part of the card config initiative. If you're not working on
# card config, you can probably ignore this.
class CardsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  #  This endpoint exists temporarily, in order to fetch Card objects
  #  for non-task-cards: Funders, Authors, etc.
  def query_name
    respond_with Card.find_by(name: params[:name])
  end

  def index
    journal_ids = current_user.filter_authorized(
      :administer,
      Journal,
      participations_only: false
    ).objects.map(&:id)

    if params[:journal_id]
      journal_ids = journal_ids.select { |j| j == params[:journal_id].to_i }
    end

    respond_with Card.where(journal_id: journal_ids)
  end

  def show
    requires_user_can(:view, card)
    respond_with card
  end

  def create
    journal = Journal.find(card_params[:journal_id])
    requires_user_can(:create_cards, journal)

    card = Card.create!(card_params)
    respond_with card
  end

  private

  def card
    @card ||= Card.find(params[:id])
  end

  def card_params
    params.require(:card).permit(
      :name,
      :journal_id
    )
  end

  def owner_klass
    potential_owner = params[:owner_type].classify.constantize
    assert(potential_owner.try(:answerable?), "resource is not answerable")

    potential_owner
  end
end
