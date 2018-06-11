class AddPublishedToSimplecSubdomains < ActiveRecord::Migration[5.1]
  def change
    add_column :simplec_subdomains, :published, :boolean,
      default: false
    add_index :simplec_subdomains, :published

    reversible do |dir|
      dir.up {
        execute <<-SQL.strip.gsub(/\s+/, ' ')
UPDATE simplec_subdomains
  SET published = true;
        SQL
      }
    end
  end
end
