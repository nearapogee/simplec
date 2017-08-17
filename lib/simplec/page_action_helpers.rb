module Simplec
  module PageActionHelpers

    # @private
    module ClassMethods; end

    module InstanceMethods

      private

      # Render the template and layout for a path.
      #
      # @param path [String] a path without a leading /
      # @param options [Hash] passed through to underlying `render`
      #
      # @!visibility public
      def render_path(path, options={})
        @page = page(path)
        render options.merge(
          template: 'simplec/pages/show',
          layout: layout(@page)
        )
      end

      # Determine the layout for a page.
      #
      # @param page [Simplec::Page]
      #
      # @return [String] layout name
      # @!visibility public
      def layout(page)
        # TODO allow config for public
        [page.layout, page.subdomain.default_layout, 'public'].
          reject(&:blank?).first
      end

    end

    # @!visibility private
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end
