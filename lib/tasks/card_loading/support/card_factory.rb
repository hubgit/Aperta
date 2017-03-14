# This class creates new valid Cards in the system by using the
# CardConfiguration classes to determine the correct Card attributes to set.
#
class CardFactory
  attr_accessor :journal

  def initialize(journal: nil)
    @journal = journal
  end

  def create(configuration_klasses)
    Array(configuration_klasses).each do |klass|
      create_from_configuration_klass(klass)
    end
  end

  private

  def create_from_configuration_klass(configuration_klass)
    existing_card = Card.find_by(name: configuration_klass.name, journal: journal, latest_version: 1)
    card = existing_card || Card.create_new!(name: configuration_klass.name,
                                             journal: journal)
    content_root = card.content_root_for_version(:latest)
    new_content = configuration_klass.content
    new_content.each do |c|
      c[:parent] = content_root
    end
    content_root.descendants.where.not(ident: nil)
                .update_all_exactly!(new_content)
  end
end
