namespace :typesetter do
  require 'pp'

  desc <<-USAGE.strip_heredoc
    Displays typesetter metadata for manual inspection. Pass in paper id.
      Usage: rake typesetter:json[<paper_id>, <destination>]
      Example: rake typesetter:json[5, em] (for paper with id 5 and destination em)
  USAGE
  task :json, [:paper_id, :destination] => :environment do |_, args|
    destination = args[:destination] || 'apex'
    Rails.application.config.eager_load_namespaces.each(&:eager_load!)
    pp Typesetter::MetadataSerializer.new(Paper.find(args[:paper_id]), destination: destination).as_json
  end

  desc <<-USAGE.strip_heredoc
    Creates a typesetter ZIP file for manual inspection.
      Usage: rake typesetter:zip[<paper_id>,<output_filename>, <destination>]
  USAGE
  task :zip, [:paper_id, :output_filename, :destination] => :environment do |_, args|
    Rails.application.config.eager_load_namespaces.each(&:eager_load!)
    paper = Paper.find(args.paper_id)
    package = ExportPackager.create_zip(paper, destination: args.destination)
    FileUtils.cp(package.path, args[:output_filename])
  end
end
