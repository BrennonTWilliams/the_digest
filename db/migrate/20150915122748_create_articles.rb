class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :title
      t.string :author
      t.string :pubDate
      t.text :summary
      t.string :image
      t.string :source
      t.string :link
      t.string :section
      t.timestamps null: false
    end
  end
end
