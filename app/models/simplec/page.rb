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
                else
                  fields
                end
      _fields.keys
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
    # @return [Array] of parent Pages
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

    # @!visibility private
    module Normalizers

      def slug=(val)
        val = val ? val.to_s.split('/').reject(&:blank?).join('/') : val
        super val
      end

      def slug
        if self.parent_id && self.parent.nil?
          self.path.to_s.split('/').reject(&:blank?).join('/')
        else
          super
        end
      end
    end
    prepend Normalizers

    class AlreadyLinkedEmbeddedImage < StandardError; end

    private

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

