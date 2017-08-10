class CreateSimplecSubdomains < ActiveRecord::Migration[5.0]
  def change
    create_table :simplec_subdomains, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :name
      t.string :default_layout

      t.timestamps
    end

    add_index :simplec_subdomains, :name, unique: true
  end
end
