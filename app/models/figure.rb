class Figure < ActiveRecord::Base
  include EventStream::Notifiable
  include ProxyableResource

  # writes to `token` attr on create
  # `regenerate_token` for new token
  has_secure_token

  belongs_to :paper

  default_scope { order(:id) }

  mount_uploader :attachment, AttachmentUploader

  def self.acceptable_content_type?(content_type)
    !!(content_type =~ /(^image\/(gif|jpe?g|png|tif?f)|application\/postscript)$/i)
  end

  def filename
    self[:attachment]
  end

  def alt
    filename.split('.').first.gsub(/#{File.extname(filename)}$/, '').humanize if filename.present?
  end

  def src
    non_expiring_proxy_url if done?
  end

  def detail_src
    non_expiring_proxy_url(version: :detail) if done?
  end

  def preview_src
    non_expiring_proxy_url(version: :preview) if done?
  end

  def access_details
    { filename: filename, alt: alt, id: id, src: src }
  end

  private

  def done?
    status == 'done'
  end
end
