class RouterUploaderService
  include UrlBuilder
  class APIError < StandardError; end

  def initialize(destination:, email_on_failure:, file_io:, filenames:, final_filename:, paper:, url:)
    @destination = destination,
    @email_on_failure = email_on_failure,
    @file_io = file_io,
    @filenames = filenames,
    @final_filename = final_filename,
    @paper = paper,
    @url = 'http://aa-dev.plos.org'
  end

  def upload
    conn = Faraday.new(url: @url) do |faraday|
      faraday.response :json
      faraday.request :multipart
      faraday.request  :url_encoded
      faraday.use :gzip
      faraday.use Faraday::Response::RaiseError
      faraday.adapter :net_http
    end

    payload = {
      metadata_filename: 'metadata.json',
      aperta_id: 'some id',
      destination: 'em',
      journal_code: 'pcompbiol',
      files: @filenames.join(','),
      # The archive_filename is not a string but the file itself.
      archive_filename: Faraday::UploadIO.new(@file_io.first, '')
    }
    response = conn.post("/api/delivery") do |request|
      request.body = payload
    end
  end
end
