class CreateSimplecDocuments < ActiveRecord::Migration[5.1]
  def change
    create_table :simplec_documents, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.uuid :document_set_id
      t.string :slug
      t.string :name
      t.boolean :required, default: false
      t.text :description
      t.string :file_uid
      t.string :file_name

      t.timestamps
    end
		add_index :simplec_documents, :document_set_id
    add_index :simplec_documents, :slug
    add_index :simplec_documents, :name

    create_table :simplec_documents_subdomains, index: false do |t|
      t.uuid :document_id
      t.uuid :subdomain_id
    end
    add_index :simplec_documents_subdomains, [:document_id, :subdomain_id],
      unique: true,
      name: 'index_simplec_documents_subdomains_unique'
  end
end
