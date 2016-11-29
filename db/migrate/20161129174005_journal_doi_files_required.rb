class JournalDoiFilesRequired < ActiveRecord::Migration
  def up
    change_column :journals, :doi_publisher_prefix, :string, null: false
    change_column :journals, :doi_journal_prefix, :string, null: false
    change_column :journals, :last_doi_issued, :string, null: false, default: "0"

    add_index :journals, [:doi_publisher_prefix], :unique => true
    add_index :journals, [:doi_journal_prefix], :unique => true
  end
end
