class OrcidAccountSerializer < ActiveModel::Serializer
  attributes :id,
    :identifier,
    :name,
    :profile_url,
    :status,
    :oauth_authorize_url

  private

  def include_name?
    is_current_user?
  end

  def include_oauth_authorize_url?
    is_current_user?
  end

  def include_status?
    is_current_user?
  end

  def is_current_user?
    current_user.id == object.user_id
  end
end