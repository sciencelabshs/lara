class CreateImageInteractives < ActiveRecord::Migration
  def change
    create_table :image_interactives do |t|
      t.string :url
      t.text :caption
      t.text :credit
      
      t.timestamps
    end
  end
end
