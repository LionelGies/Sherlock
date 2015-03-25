class CreateTextSnippets < ActiveRecord::Migration
  def change
    create_table :text_snippets do |t|
#      t.references :user
#     t.string :title
#      t.text :body, :limit => 64.kilobytes + 1
      t.timestamps
    end
#    add_index :text_snippets, :user_id
  end
end
