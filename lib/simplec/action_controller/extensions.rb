module Simplec
  module ActionController
    module Extensions

      def self.included(receiver)
        receiver.helper_method :subdomain, :page,
          :simplec_path_for, :simplec_url_for
      end

      # Get the subdomain.
      # TODO docs
      def subdomain(name=nil)
        name          ||= request.subdomain
        @_subdomains  ||= Hash.new
        return @_subdomains[name] if @_subdomains[name]
        @_subdomains[name] = Subdomain.find_by!(name: name)
      end

      # TODO docs
      # @param path [String] path with no leading /
      #
      # @return [Simplec::Page]
      def page(path, options={})
        @_page ||= Hash.new
        key = "#{subdomain(options[:subdomain])};#{path}"
        return @_page[key] if @_page[key]

        # TODO add raise option for find_by!
        @_page[key] = subdomain(options[:subdomain]).pages.
          includes(:subdomain).find_by!(path: path)
      end

      # Get the path of a page.
      #
      # By default, if the Page cannot be located nil will be the result.
      #
      # @param page_or_path [Simplec::Page, String]
      #   If a page it will find the page.
      #   If a path it will find the page from the given path (no leading /).
      #
      # @param options [Hash] options
      # @option options [Symbol] :raise
      #   If :raise is true, then ActiveRecord::RecordNotFound will be raised
      #   if the page cannot be found.
      #
      # @raise [ActiveRecord::RecordNotFound]
      #   if options[:raise] is true and Page cannot be located
      #
      # @return [String, nil] path of page, or nil
      def simplec_path_for(page_or_path, options={})
        page = page_for(page_or_path, options.extract!(:raise))
        return unless page
        simplec.page_path options.merge(
          path: page.path
        )
      end

      # Get the url of a page.
      #
      # By default, if the Page cannot be located nil will be the result.
      #
      # @param page_or_path [Simplec::Page, String]
      #   If a page it will find the page.
      #   If a path it will find the page from the given path (no leading /).
      #
      # @param options [Hash] options
      # @option options [Symbol] :raise
      #   If :raise is true, then ActiveRecord::RecordNotFound will be raised
      #   if the page cannot be found.
      #
      # @raise [ActiveRecord::RecordNotFound]
      #   if options[:raise] is true and Page cannot be located
      #
      # @return [String, nil] path of page, or nil
      def simplec_url_for(page_or_path, options={})
        page = page_for(page_or_path, options.extract!(:raise))
        return unless page
        simplec.page_url options.merge(
          subdomain: page.subdomain.try(:name),
          path: page.path
        )
      end

      private

      def page_for(page_or_path, options={})
        page = page_or_path.is_a?(Page) ?
          page_or_path : page(page_or_path, options)

        unless page
          raise ActiveRecord::RecordNotFound if options[:raise]
          return nil
        end

        page
      end
    end
  end
end
