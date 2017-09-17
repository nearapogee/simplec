class AddSearchToSimplecPages < ActiveRecord::Migration[5.0]
  def change
    add_column :simplec_pages, :tsv, :tsvector
    add_column :simplec_pages, :query, :jsonb
    add_column :simplec_pages, :text, :jsonb

    add_index :simplec_pages, :tsv, using: :gin

    reversible do |dir|
      dir.up {
        execute <<-SQL.gsub(/\s+/, " ").strip
ALTER TABLE simplec_pages ALTER COLUMN query
  SET DEFAULT '{}'::JSONB;
ALTER TABLE simplec_pages ALTER COLUMN text
  SET DEFAULT '{"a": null, "b": null, "c": null, "d": null}'::JSONB;

UPDATE simplec_pages
  SET
    query = '{}'::JSONB,
    text = '{"a": null, "b": null, "c": null, "d": null}'::JSONB;

CREATE INDEX simplec_pages_query ON simplec_pages
  USING GIN (query jsonb_path_ops);

CREATE FUNCTION simplec_pages_search_tsvector_update_trigger() RETURNS trigger AS $$
begin
  new.tsv :=
    setweight(
      to_tsvector('pg_catalog.english', coalesce(new.text ->> 'a','')), 'A'
    ) ||
    setweight(
      to_tsvector('pg_catalog.english', coalesce(new.text ->> 'b','')), 'B'
    ) ||
    setweight(
      to_tsvector('pg_catalog.english', coalesce(new.text ->> 'c','')), 'C'
    ) ||
    setweight(
      to_tsvector('pg_catalog.english', coalesce(new.text ->> 'd','')), 'D'
    );
  return new;
end

$$ LANGUAGE plpgsql;
CREATE TRIGGER simplec_pages_search_tsvector_update BEFORE INSERT OR UPDATE
  ON simplec_pages FOR EACH ROW
  EXECUTE PROCEDURE simplec_pages_search_tsvector_update_trigger();
        SQL
      }
      dir.down {
        execute <<-SQL.gsub(/\s+/, " ").strip
DROP TRIGGER IF EXISTS simplec_pages_search_tsvector_update ON simplec_pages;
DROP FUNCTION IF EXISTS simplec_pages_search_tsvector_update_trigger();
DROP INDEX simplec_pages_query;
        SQL
      }
    end
  end
end
