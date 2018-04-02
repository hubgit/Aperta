# Serializes related articles, which represent links between
# this manuscript and others, published or not.
class RelatedArticleSerializer < AuthzSerializer
  attributes :id,
             :paper_id,
             :linked_doi,
             :linked_title,
             :additional_info,
             :send_manuscripts_together,
             :send_link_to_apex
end
