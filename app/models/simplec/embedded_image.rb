# An embedded image in an editor field.
#
# For the most part you don't need to utilize this record. These records are
# created by summernote and the administration of creating them is handled
# by the Simplec Engine.
#
# There is an #embedded_images association on a `Simplec::Page` record.
#
module Simplec
  class EmbeddedImage < ApplicationRecord
    belongs_to :embeddable,
      polymorphic: true,
      optional: true

    dragonfly_accessor :asset

    # Dragonfly url for the asset.
    #
    # @return [String] the url for the dragonfly asset
    def url
      return unless self.asset
      return self.asset.url unless persisted?
      self.asset.url(ei: Base64.urlsafe_encode64(self.id.to_s))
    end
    alias_method :asset_url, :url

  end
end
