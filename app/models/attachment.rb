# Attachment represents a generic file/resource. It is intended to be used
# as a base-class.
#
# Attachment mounts its file using the AttachmentUploader class, which has
# provisions for creating preview and detail versions of uploaded images.
# For the time being any subclass of Attachment will use the AttachmentUploader
# as well.
class Attachment < ActiveRecord::Base
  include EventStream::Notifiable
  include ProxyableResource
  include Snapshottable

  IMAGE_TYPES = %w(jpg jpeg tiff tif gif png eps tif)

  self.snapshottable = true

  STATUS_DONE = 'done'

  mount_snapshottable_uploader :file, AttachmentUploader

  def self.authenticated_url_for_key(key)
    uploader = new.file
    CarrierWave::Storage::Fog::File.new(
      uploader,
      uploader.send(:storage),
      key
    ).url
  end

  belongs_to :owner, polymorphic: true
  belongs_to :paper

  validates :owner, presence: true

  # set_paper is required when creating attachments thru associations
  # where the owner is the paper, it bypasses the owner= method.
  after_initialize :set_paper, if: :new_record?

  def download!(url)
    @downloading = true
    file.download! url
    self.file_hash = Digest::SHA256.hexdigest(file.file.read)
    self.s3_dir = file.generate_new_store_dir
    self.title = build_title
    self.status = STATUS_DONE
    # Using save! instead of update_attributes because the above are not the
    # only attributes that have been updated. We want to persist all changes
    save!
    refresh_resource_token!(file)
    @downloading = false
    on_download_complete
  rescue Exception => ex
    on_download_failed(ex)
  ensure
    @downloading = false
  end

  def destroy_resource_token!
    return if snapshotted?
    super
  end

  def downloading?
    @downloading
  end

  def on_download_complete
    # no-op. Sweet hook method to add in a subclass to perform actions after an
    # attachment is downloaded.
  end

  def on_download_failed(exception)
    fail exception
  end

  def url(*args)
    file.url(*args)
  end

  def filename
    self[:file]
  end

  def done?
    status == STATUS_DONE
  end

  def owner=(new_owner)
    super
    set_paper
  end

  def snapshot_key
    file.current_path
  end

  def snapshotted?
    if @previous_model_for_file
      @previous_model_for_file.snapshot.present?
    else
      snapshot.present?
    end
  end

  def task
    if owner_type == 'Task'
      owner
    end
  end

  # These methods were pulled up from Attachment subclasses
  def src
    non_expiring_proxy_url if done?
  end

  def access_details
    { filename: filename, alt: alt, id: id, src: src }
  end

  def detail_src(**opts)
    return unless image?

    non_expiring_proxy_url(version: :detail, **opts) if done?
  end

  def preview_src
    return unless image?

    non_expiring_proxy_url(version: :preview) if done?
  end

  def image?
    if file.file
      IMAGE_TYPES.include? file.file.extension
    else
      false
    end
  end

  protected

  def build_title
    title || file.filename
  end

  private

  def set_paper
    if owner_type == 'Paper'
      self.paper_id = owner_id
    elsif owner.respond_to?(:paper)
      self.paper = owner.paper
    end
  end
end
