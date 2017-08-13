module Simplec
  module ActionController
    module Extensions

      def self.included(receiver)
        receiver.helper_method :subdomain, :page,
          :simplec_path, :simplec_url
      end

      def subdomain(name=nil)
        name          ||= request.subdomain
        @_subdomains  ||= Hash.new
        return @_subdomains[name] if @_subdomains[name]
        @_subdomains[name] = Subdomain.find_by!(name: name)
      end

      def page(path, options={})
        @_page ||= Hash.new
        return @_page[path] if @_page[path]

        _subdomain = subdomain
        _subdomain = Subdomain.find_by!(
          name: options[:subdomain]
        ) if options[:subdomain]

        @_page[path] = _subdomain.pages.find_by!(path: path)
      end

      def simplec_path(page_or_path, options={})
        # TODO cache page_paths
        _page = page_or_path.is_a?(Page) ?
          page_or_path : page(page_or_path, options)

        unless _page
          raise ActiveRecord::RecordNotFound if options[:raise]
          return nil
        end

        _page.path
      end

      def simplec_url(page_or_path, options={})
        # TODO cache page_urls
        _page = page_or_path.is_a?(Page) ?
          page_or_path : page(page_or_path, options)

        unless _page
          raise ActiveRecord::RecordNotFound if options[:raise]
          return nil
        end

        URI.join(root_url(subdomain: _page.subdomain.try(:name)), _page.path).to_s
      end
    end
  end
end
