#
# Tracks similarity check requests to iThenticate. ithenticate_id is the id
# generated by iThenticate for the similarity check request. We query their
# API by this number to see if the report has completed yet.
#
class CreateSimilarityChecks < ActiveRecord::Migration
  def change
    create_table :similarity_checks do |t|
      t.integer :ithenticate_document_id
      t.datetime :ithenticate_report_completed_at
      t.datetime :timeout_at
      t.string :document_s3_url
      t.integer :report_id # TODO: add ithenticate_
      t.integer :score # TODO: add ithenticate_
      t.references :versioned_text, foreign_key: true, null: false
      t.string :state, null: false
      t.timestamps null: false
    end
  end
end
