class CreateSimplecEmbeddedImages < ActiveRecord::Migration[5.0]
  def change
    create_table :simplec_embedded_images, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :embeddable_type
      t.id :embeddable_id
      t.string :asset_uid
      t.string :asset_name

      t.timestamps
    end
  end
end
