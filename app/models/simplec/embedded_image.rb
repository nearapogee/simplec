module Simplec

  # An embedded image in an editor field.
  #
  # For the most part you don't need to utilize this record. These records are
  # created by summernote and the administration of creating them is handled
  # by the Simplec Engine.
  #
  # There is an #embedded_images association on a `Simplec::Page` record.
  #
  # @!visibility public
  class EmbeddedImage < ApplicationRecord

    # @!attribute embeddable
    # The object that owns the embedded image
    # @return [Object, nil] An ActiveRecord object
    belongs_to :embeddable,
      polymorphic: true,
      optional: true

    # @!attribute asset
    #   @return [Dragonfly::Model::Attachment, nil] The embedded asset
    dragonfly_accessor :asset

    # @!attribute embeddable_type
    #   @return [String, nil] The type of the #embeddable association

    # @!attribute embeddable_id
    #   @return [String, Integer, nil] The uuid (or id) of the #embeddable association

    # @!attribute asset_uid
    #   @return [String, nil] The unique id of the Dragonfly #asset

    # @!attribute asset_name
    #   @return [String, nil] The name of the Dragonfly #asset

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
