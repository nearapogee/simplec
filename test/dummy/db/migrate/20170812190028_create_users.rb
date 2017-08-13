class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :email
      t.string :password_digest
      t.boolean :admin, default: false
      t.boolean :sysadmin, default: false

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :admin
    add_index :users, :sysadmin
  end
end
