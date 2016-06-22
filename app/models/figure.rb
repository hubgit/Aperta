# A manuscript figure.
class Figure < Attachment
  include CanBeStrikingImage

  default_scope { order(:id) }

  mount_uploader :file, AttachmentUploader

  after_save :insert_figures!, if: :should_insert_figures?
  after_destroy :insert_figures!

  delegate :insert_figures!, to: :paper

  def self.acceptable_content_type?(content_type)
    !!(content_type =~ /(^image\/(gif|jpe?g|png|tif?f)|application\/postscript)$/i)
  end

  def alt
    filename.split('.').first.gsub(/#{File.extname(filename)}$/, '').humanize if filename.present?
  end

  def src
    non_expiring_proxy_url if done?
  end

  def detail_src(**opts)
    non_expiring_proxy_url(version: :detail, **opts) if done?
  end

  def preview_src
    non_expiring_proxy_url(version: :preview) if done?
  end

  def access_details
    { filename: filename, alt: alt, id: id, src: src }
  end

  def title_rank_regex
    /fig(ure)?[^[:alnum:]]*(?<label>\d+)/i
  end

  def create_title_from_filename
    return if title
    self.title = "Unlabeled"
    title_rank_regex.match(attachment.filename) do |match|
      self.title = "Fig. #{match['label']}"
    end
  end

  def rank
    return 0 unless title
    number_match = title.match /\d+/
    if number_match
      number_match[0].to_i
    else
      0
    end
  end

  private

  def should_insert_figures?
    (title_changed? || file_changed?) && all_figures_done?
  end

  def all_figures_done?
    paper.figures.all?(&:done?)
  end
end
