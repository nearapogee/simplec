module Simplec
  module ActionView
    module Helper

      def head(page)
        content_for :title, page.title
        content_for :meta_description, page.meta_description
      end

      def title
        content_for :title
      end

      def meta_description_tag
        tag :meta, name: 'description', content: content_for(:meta_description)
      end

      def template(page)
        _template = page.type.demodulize.downcase
        render "pages/#{_template}"
      end

      def page_field(f, options={})
        render "simplec/fields/#{options[:type]}", options.merge(f: f)
      end

      # Retreive a document.
      #
      # slug - matching a Document slug.
      # options[:subdomain] - a string matching a Subdomain name, find a document
      #                       from another subdomain
      # options[:raise] - if true, casuse a 404 if document isn't found
      #
      # Example:
      #
      #   -# Save as...
      #   <%= link_to doc('/permission/general').name,
      #     doc('/permission/general').path,
      #     download: true %>
      #
      #   -# Display in new window...
      #   <%= link_to doc('/permission/general').name,
      #     doc('/permission/general').path,
      #     target: '_blank' %>
      #
      def doc(slug, options={})
        @_docs ||= Hash.new
        key = "[#{options[:subdomain]}][#{slug}]"
        return @_docs[key] if @_docs[key]
        @_docs[key] = subdomain(options[:subdomain]).
          documents.find_by(slug: slug)
        raise ActiveRecord::RecordNotFound if options[:raise] && !@_docs[key]
        @_docs[key]
      end

      # Retreive a document.
      #
      # slug - matching a Document slug.
      # options[:subdomain] - a string matching a Subdomain name, find a document
      #                       set from another subdomain
      # options[:raise] - if true, casuse a 404 if document set isn't found
      #
      # Example:
      #
      #   <% docset('/faith').each do |doc| %>
      #     <%= link_to doc.name, doc.path %>
      #   <% end %>
      #
      def docset(slug, options={})
        @_docsets ||= Hash.new
        key = "[#{options[:subdomain]}][#{slug}]"
        return @_docsets[key] if @_docsets[key]
        set = subdomain(options[:subdomain]).
          document_sets.find_by(slug: slug)
        raise ActiveRecord::RecordNotFound if options[:raise] && !set
        @_docsets[key] = set.documents
      end

      # page_or_path - a page object or a path of a page
      # options[:subdomain] - a string matching a Subdomain name, find a page
      #                       from another subdomain
      # options[:raise] - if true, casuse a 404 if a page set isn't found
      #
      # Example:
      #
      #   <% subpages('/give-volunteer', conditions: ->{ order(title: :asc) }).each do |page| %>
      #     ... do something with page ...
      #   <% end%>
      def subpages(page_or_path, options={})
        if options[:conditions] && !options[:conditions].respond_to?(:call)
          raise ArgumentError, <<-ERROR
          #{options[:conditions]} was passed as :conditions but is not callable.
"Pass a callable instead: `conditions: -> { where(approved: true) }`
          ERROR
        end

        @_subpages ||= Hash.new # TODO apply new conditions after cache
        key = "[#{options[:subdomain]}][#{page_or_path}]"

        unless @_subpages[key]
          page = page_or_path.is_a?(Page) ? page_or_path : nil
          page ||= subdomain(options[:subdomain]).pages.find_by(path: page_or_path)

          unless page
            raise ActiveRecord::RecordNotFound if options[:raise]
            return @_subpages[key] = Array.new
          end

          @_subpages[key] = page.subpages
        end

        @_subpages[key].respond_to?(:merge) && options[:conditions] ?
          @_subpages[key].merge(options[:conditions]) : @_subpages[key]
      end
    end

  end
end
