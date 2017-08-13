class CreateSimplecEmbeddedImages < ActiveRecord::Migration[5.0]
  def change
    create_table :simplec_embedded_images, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :embeddable_type
      t.integer :embeddable_id
      t.string :asset_uid
      t.string :asset_name

      t.timestamps
    end

    add_index :simplec_embedded_images, [:embeddable_type, :embeddable_id],
      name: 'simplec_embedded_images_type_id_index'
  end
end
