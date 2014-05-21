class PaperSerializer < ActiveModel::Serializer
  attributes :id, :short_title, :title, :body, :submitted, :paper_type

  %i!phases figures authors!.each do |relation|
    has_many relation, embed: :ids, include: true
  end

  %i!assignees editors reviewers!.each do |relation|
    has_many relation, embed: :ids, include: true, root: :users
  end

  has_many :tasks, embed: :ids, polymorphic: true
  has_one :journal, embed: :ids, include: true

end
