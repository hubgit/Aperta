# PDF Converter -- Deprecated
class PDFConverter
  include DownloadablePaper

  def initialize(paper, downloader = nil)
    @paper = paper
    @downloader = downloader # a user
    @publishing_info_presenter =
      PublishingInformationPresenter.new @paper, @downloader
  end

  def convert
    PDFKit.new(pdf_html,
               footer_right: @publishing_info_presenter.downloader_name,
               footer_font_name: 'Times New Roman',
               footer_font_size: '10').to_pdf
  end

  def supporting_information_files
    @paper.supporting_information_files.map do |si_file|
      PaperConverters::SupportingInformationFileProxy
        .from_supporting_information_file(si_file)
    end
  end

  def pdf_html
    render(
      'pdf',
      layout: nil,
      locals: {
        should_proxy_previews: false,
        paper: @paper,
        paper_body: paper_body,
        publishing_info_presenter: @publishing_info_presenter,
        supporting_information_files: supporting_information_files
      }
    )
  end
end
