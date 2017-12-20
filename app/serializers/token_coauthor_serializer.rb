class TokenCoauthorSerializer < ActiveModel::Serializer
  attributes :id, :token, :created_at, :confirmation_state, :paper_title, :coauthors, :journal_logo_url

  def paper_title
    object.paper.title
  end

  def coauthors
    object.paper.all_authors.map do |author|
      { full_name: author.full_name, affiliation: author.affiliation }
    end
  end

  def confirmation_state
    object.co_author_state
  end

  def journal_logo_url
    object.paper.journal.logo_url
  end
end
