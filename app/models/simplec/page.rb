module Simplec

  # This class represents a page in the system.
  #
  # == Model and Template Relationship.
  #
  # This is a para with `code`. WTF
  #
  # Each page has:
  #
  # - a class located in: `app/models/page/NAME.rb`
  #
  # - a partial template in: +app/views/pages/_NAME.html.erb+
  #
  # Where NAME is the demodulized, snake-case name of the Page Subclass.
  #
  # @example Class and template
  #
  #   # app/models/page/home.rb
  #   class Page::Home < Page
  #     field :h1
  #   end
  #
  #   <!-- app/views/pages/_home.html.erb -->
  #   <h1>My Application</h1>
  #   <h2><%= @page.tagline %></h2>
  #
  # @!visibility public
  class Page < ApplicationRecord

    FILE_FIELDS = [:file, :image].freeze

    belongs_to :subdomain,
      optional: false
    belongs_to :parent,
      class_name: 'Page',
      optional: true
    has_many :children,
      class_name: 'Page',
      foreign_key: :parent_id
    has_many :embedded_images,
      as: :embeddable,
      dependent: :delete_all

    validates :type,
      presence: true
    validates :path,
      uniqueness: { scope: :subdomain_id }
    validate :validate_path_not_nil!
    validates :layout,
      inclusion: {in: :layouts, allow_blank: true}
    validates :title,
      presence: true

    before_validation :match_parent_subdomain
    before_validation :build_path
    after_save :link_embedded_images!
    after_save :index!

    # @!attribute slug
    #   The value is normalized to a string starting without a leading slash
    #   and ending without a slash. Case is not changed.
    #   @return [String]

    # @!attribute [r] path
    #   The the path is computed from the slug and the sum all parent pages.
    #   @return [String]

    # @!attribute title
    #   This is the title of the page.
    #   @return [String]

    # @!attribute meta_description
    #   This is the meta description tag for the page.
    #   @return [String]

    # @!attribute layout
    #   This is the layout to be used when the page is rendered. This attribute
    #   overrides the associated Subdomain's default_layout.
    #
    #   See Simplec::Subdomain#layouts to get a list of optional layouts.
    #
    #   @return [String]

    # @!attribute fields
    #   JSONB Postgres field that holds all defined fields. Use only if you
    #   know what you are doing.
    #   @return [JSON]

    # @!method search(term, options={})
    #
    # If the term is nil or blank, all results will be returned.
    #
    # @param term [String]
    # @param options [Hash]
    # @option options [Class, Array, String] :types
    #   A Class or Array of Classes (of page types, typically `Page::Home`) to
    #   limit results to.
    # @option options [Symbol, String] all other options
    #   All other options are matched to the `query` JSONB field. These are
    #   all direct matches on the indexed `query` field. If you want to do
    #   anything more complicated, append it to the scope returned.
    #
    # @return [ActiveRecord::Relation] a relation for the query
    # @!scope class
    scope :search, ->(term, options={}) {
      _types      = Array(options.delete(:types))
      _subdomains = Array(options.delete(:subdomains))

      query = all
      query = query.includes(:subdomain).
        where(simplec_subdomains: {name: _subdomains}) if _subdomains.any?
      query = query.where(type: _types) if _types.any?
      options.each { |k,v| query = query.where("query->>:k = :v", k: k, v: v) }

      if term.blank?
        query
      else
        tsq = tsquery term
        query.where("tsv @@ #{tsq}").order("ts_rank_cd(tsv, #{tsq}) DESC")
      end
    }

    # Define a field on the page
    #
    # There is as template for each type for customization located in:
    #   app/views/shared/fields/_TYPE.html.erb
    #
    # Defines a field on a subclass. This creates a getter and setter for the
    # name passed in. The options are used when building the administration forms.
    #
    # Regular dragonfly validations are available on :file and :image fields.
    # http://markevans.github.io/dragonfly/models#validations
    #   :string - yields a text input
    #   :text - yields a textarea
    #   :editor - yields a summernote editor
    #   :file - yields a file field
    #   :image - yields a file field with image preview
    #
    # @param name [String] name of field to be defined
    # @param options [Hash] field options
    # @option options [Symbol] :type one of :string (default), :text, :editor, :file, :image
    def self.field(name, options={})
      fields[name] = {name: name, type: :string}.merge(options)
      if FILE_FIELDS.member?(fields[name][:type])
        dragonfly_accessor name
        data_field :"#{name}_uid"
        data_field :"#{name}_name"
      else
        data_field(name)
      end
    end

    # @return [Hash]
    def self.fields
      @fields ||= Hash.new
    end

    # Return a constantized type, whitelisted by known subclasses.
    #
    # @raise [RuntimeError] if Page subclass isn't defined.
    # @return [Class]
    def self.type(type)
      ::Page rescue raise '::Page not defined, define it in app/models'
      raise 'Unsupported Page Type; define in app/models/page/' unless ::Page.subclasses.map(&:name).
        member?(type)
      type.constantize
    end

    # Return names of fields.
    #
    # type: :file, is the only option
    #
    def self.field_names(type=nil)
      _fields = case type
                when :file
                  fields.select {|k, v| FILE_FIELDS.member?(v[:type])}
                when :textual
                  fields.select {|k, v| !FILE_FIELDS.member?(v[:type])}
                else
                  fields
                end
      _fields.keys
    end

    # Set extra attributes on the record for querying.
    #
    # @example set attributes
    #   class Page::Home < Page
    #     has_many :tags
    #
    #     field :category
    #
    #     # Where category is a Simplec::Page::field and tags is a defined
    #     # method.
    #     search_query_attributes! :category, :tags
    #
    #     def tags
    #       self.tags.pluck(:name)
    #     end
    #   end
    #
    #   # Built-in matching
    #   Page.search('foo', category: 'how-to')
    #
    #   # Manual matching
    #   Page.search('bar').where("query->>'tags' IN ('home', 'garden')")
    #
    def self.search_query_attributes!(*args)
      @_search_query_attrs = args.map(&:to_sym)
    end

    # Get extra attributes on the record for querying.
    #
    # See #search_query_attributes! for more information.
    #
    # @return [Array] of attributes
    def self.search_query_attributes
      @_search_query_attrs = Set.new(@_search_query_attrs).add(:id).to_a
    end

    # Index every record.
    #
    # Internally this method iterates over all pages in batches of 3.
    #
    # @return [NilClass]
    def self.index!
      find_each(batch_size: 3) { |page| page.index! }
    end

    # Create a to_tsquery statement.
    #
    # Mainly used internally, but could be used in custom queries.
    #
    # @param input [String] string to be queried
    # @param options [Hash] optional
    # @option options [String] :language defaults to 'english'
    #   This is really a future addition, all of the tsvector fields are set to
    #   'english'.
    #
    # @return [String] a to_tsquery statement
    def self.tsquery(input, options={})
      options[:language] ||= 'english'
      value = input.to_s.strip
      value  = value.
        gsub('(', '').
        gsub(')', '').
        gsub(%q('), '').
        gsub(' ', '\\ ').
        gsub(':', '').
        gsub("\t", '').
        gsub("!", '')
      value << ':*'
      query = "to_tsquery(?, ?)"
      sanitize_sql_array([query, options[:language], value])
    end

    # Return field options for building forms.
    #
    def field_options
      self.class.fields.values
    end

    # List parents, closest to furthest.
    #
    # This is a recursive, expensive call.
    #
    def parents
      page, parents = self, Array.new
      while page.parent
        page = page.parent
        parents << page
      end
      parents
    end

    # Build the path of the page to be used in routing.
    #
    # Used as a before validation hook.
    #
    # @return [String] the computed path for the page
    def build_path
      _pages = self.parents.reverse + [self]
      self.path = _pages.map(&:slug).reject(&:blank?).join('/')
    end

    # Sets the #subdomain t that of the parent.
    #
    # All pages need to have a matching subdomain to parent page. Does nothing
    # if there is no parent.
    #
    # Used as a before validation hook.
    #
    # @return [Simplec::Subdomain] the parent's subdomain
    def match_parent_subdomain
      return unless self.parent
      self.subdomain = self.parent.subdomain
    end

    # Search all of the fields text and create an array of all found
    # Simplec::EmbeddedImages.
    #
    # @return [Array] of Simplec::EmbeddedImages
    def find_embedded_images
      text = self.fields.values.join(' ')
      matches = text.scan(/ei=([^&]*)/)
      encoded_ids = matches.map(&:first)
      ids = encoded_ids.map { |eid| Base64.urlsafe_decode64(URI.unescape(eid)) }
      EmbeddedImage.includes(:embeddable).find(ids)
    end

    # Set this instance as the #embeddable association on the
    #   Simplec::EmbeddedImage
    #
    # Used as an after_save hook.
    #
    # @return [Array] of Simplec::EmbeddedImages
    def link_embedded_images!
      images = self.find_embedded_images
      images.each do |image|
        raise AlreadyLinkedEmbeddedImage if image.embeddable &&
          image.embeddable != self
        image.update!(embeddable: self)
      end
    end

    # Get layout options.
    #
    # See Simplec::Subdomain#layouts.
    #
    # @return [Array] of layout String names
    def layouts
      @layouts ||= Subdomain.new.layouts
    end

    # Index this record for search.
    #
    # Internally, this method uses update_columns so it can be used in
    # `after_save` callbacks, etc.
    #
    # @return [Boolean] success
    def index!
      set_search_text!
      set_query_attributes!
      update_columns text: self.text, query: self.query
    end

    # Extract text out of HTML or plain strings. Basically removes html
    # formatting.
    #
    # @param attributes [Symbol, String]
    #   variable list of attributes or methods to be extracted for search
    #
    # @return [String] content of each attribute separated by new lines
    def extract_search_text(*attributes)
      Array(attributes).map { |meth|
        Nokogiri::HTML(self.send(meth)).xpath("//text()").
          map {|node| text = node.text; text.try(:strip!); text}.join(" ")
      }.reject(&:blank?).join("\n")
    end

    # Set the text which will be index.
    #
    # a title, meta_description
    # b slug, path (non-printable, add tags, added terms)
    # c textual fields
    # d (reserved for sub-records, etc)
    #
    # 'a' correlates to 'A' priority in Postgresql. For more information:
    # https://www.postgresql.org/docs/9.6/static/functions-textsearch.html
    #
    def set_search_text!
      self.text['a'] = extract_search_text :title, :meta_description
      self.text['b'] = extract_search_text :slug, :path
      self.text['c'] = extract_search_text *self.class.field_names(:textual)
      self.text['d'] = nil
    end

    # Build query attribute hash.
    #
    # Internally stored as JSONB.
    #
    # @return [Hash] to be set for query attribute
    def set_query_attributes!
      attr_names = self.class.search_query_attributes.map(&:to_s)
      self.query = attr_names.inject({}) { |memo, attr|
        memo[attr] = self.send(attr)
        memo
      }
    end

    # @!visibility private
    module Normalizers
      def slug=(val)
        super clean_path(val)
      end

      def slug
        if self.parent_id && self.parent.nil?
          clean_path(self.path)
        else
          super
        end
      end
    end
    prepend Normalizers

    class AlreadyLinkedEmbeddedImage < StandardError; end

    private

    def clean_path(val)
      val ?
        val.to_s.strip.gsub(/[\s-]+/, '-').gsub(/[^\w-]/, '').split('/').reject(&:blank?).join('/') :
        val
    end

    def validate_path_not_nil!
      return unless self.path.nil?
      errors.add :path, "cannot be nil"
    end

    def self.data_field(name)
      define_method(name) { fields[name.to_s] }
      define_method("#{name}=") { |val| fields[name.to_s] = val }
    end
  end
end

