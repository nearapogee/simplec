module Simplec
  module PageActionHelpers

    # @private
    module ClassMethods; end

    module InstanceMethods

      private

      def render_path(path)
        @page = page(path)
        render template: 'simplec/pages/show', layout: layout(@page)
      end

      def layout(page)
        # TODO allow config for public
        [page.layout, page.subdomain.default_layout, 'public'].
          reject(&:blank?).first
      end

    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end
