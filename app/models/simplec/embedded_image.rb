module Simplec
  class EmbeddedImage < ApplicationRecord
    belongs_to :embeddable,
      polymorphic: true,
      optional: true

    dragonfly_accessor :asset

    def url
      return unless self.asset
      return self.asset.url unless persisted?
      self.asset.url(ei: Base64.urlsafe_encode64(self.id.to_s))
    end
    alias_method :asset_url, :url

  end
end
