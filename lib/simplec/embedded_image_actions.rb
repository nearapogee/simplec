module Simplec
  module EmbeddedImageActions
    module ClassMethods; end

    module InstanceMethods

      def create
        @embedded_image = EmbeddedImage.new(embedded_image_params)
        if @embedded_image.save
          respond_to do |format|
            format.json {
              render status: 201, location: @embedded_image.url,
                json: @embedded_image.slice(:id, :asset_name, :asset_url)
            }
          end
        else
          respond_to do |format|
            format.json {
              render status: 422, json: @embedded_image.errors
            }
          end
        end
      end

      private

      def embedded_image_params
        params.permit(:asset_url, :asset_name)
      end

    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end
