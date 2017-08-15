class CreateSimplecDocumentSets < ActiveRecord::Migration[5.1]
  def change
    create_table :simplec_document_sets, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :slug
      t.string :name
      t.boolean :required, default: false
      t.text :description

      t.timestamps
    end
    add_index :simplec_document_sets, :slug
    add_index :simplec_document_sets, :name

    create_table :simplec_document_sets_subdomains, index: false do |t|
      t.uuid :document_set_id
      t.uuid :subdomain_id
    end
    add_index :simplec_document_sets_subdomains, [:document_set_id, :subdomain_id],
      unique: true,
      name: 'index_simplec_document_sets_subdomains_unique'
  end
end
