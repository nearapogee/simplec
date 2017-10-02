module Simplec
  class Document < ApplicationRecord

    belongs_to :document_set,
      optional: true
    has_and_belongs_to_many :subdomains

    dragonfly_accessor :file

    validates :name,
      presence: true
    validate :validate_subdomain_or_set!
    validate :validate_slug!

    def path
      self.file.url
    end

    # @!visibility private
    module Normalizers
      def slug=(val)
        super val.blank? ? nil : val
      end
    end
    prepend Normalizers

    private

    def validate_subdomain_or_set!
      return if self.subdomains.length > 0
      return if self.document_set
      errors.add :subdomain_ids, 'either a document set or at least one subdomain is required'
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
