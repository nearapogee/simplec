module Simplec
  class DocumentSet < ApplicationRecord

    has_many :documents
    has_and_belongs_to_many :subdomains

    validates :name,
      presence: true
    validate :validate_subdomain!
    validate :validate_slug!

    # @!visibility private
    module Normalizers
      def slug=(val)
        super val.blank? ? nil : val
      end
    end
    prepend Normalizers

    private

    def validate_subdomain!
      return if self.subdomains.length > 0
      errors.add :subdomain_ids, 'at least one is required'
    end

    def validate_slug!
      return if self.slug.blank?
      similar = self.class.where(slug: self.slug).where.not(id: self.id)
      return if similar.size == 0
      return if (
        similar.map(&:subdomain_ids).flatten & self.subdomain_ids
      ).length == 0
      errors.add :slug, 'must be unique across linked subdomains'
    end

  end
end
