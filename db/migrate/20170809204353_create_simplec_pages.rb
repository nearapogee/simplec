class CreateSimplecPages < ActiveRecord::Migration[5.0]
  def change
    create_table :simplec_pages, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :type
      t.uuid :subdomain_id
      t.string :slug
      t.string :path
      t.string :title
      t.string :meta_description
      t.jsonb :fields
      t.string :layout

      t.timestamps
    end

		add_index :simplec_pages, :type
    add_index :simplec_pages, :subdomain_id
    add_index :simplec_pages, :parent_id
    add_index :simplec_pages, :path
    add_index :simplec_pages, [:subdomain_id, :path], unique: true

    reversible do |dir|
      dir.up {
        execute "ALTER TABLE simplec_pages ALTER COLUMN fields SET DEFAULT '{}'::JSONB"
      }
    end

  end
end
