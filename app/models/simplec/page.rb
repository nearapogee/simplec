# Simplec::Page
#
# This class represents a page in the system.
#
# Each page has a class located in:
#   app/models/page/NAME.html.erb
#
# Each page has a partial template in:
#   app/views/pages/_NAME.html.erb
#
#   Where NAME is the demodulized, snake-case name of the Page Subclasss. For
#   example:
#
#     class Page::Home < Page
#       field :h1
#     end
#
#   Would live in app/models/page/home.html.erb and have a template in
#   app/views/pages/_home.html.erb.
#
#   Each page has the following attributes by default:
#     - page.title
#
# Read the documentation below for the class method .field, it is the most
# used method.
#
#
module Simplec
  class Page < ApplicationRecord


    # TODO Document FILE_FIELDS constant
    #
		FILE_FIELDS = [:file, :image].freeze

		belongs_to :subdomain,
			optional: false
		belongs_to :parent,
			class_name: 'Page',
			optional: true
		has_many :childern,
			class_name: 'Page',
			foreign_key: :parent_id
		has_many :embedded_images,
			as: :embeddable,
			dependent: :delete_all

		validates :type,
			presence: true
		validates :path,
			presence: true,
			uniqueness: { scope: :subdomain_id }
		validates :layout,
			inclusion: {in: :layouts, allow_blank: true}
		validates :title,
			presence: true

		before_validation :match_parent_subdomain
		before_validation :build_path
		after_save :link_embedded_images!

		# Define a field on the page.
		#
		# - name - name of field
		# - options[:type] - :string (default), :text, :editor, :file, :image
		#   :string - yields a text input
		#   :text - yields a textarea
		#   :editor - yields a summernote editor
		#   :file - yields a file field
		#   :image - yields a file field with image preview
		#
		# There is as template for each type for customization located in:
		#   app/views/shared/fields/_TYPE.html.erb
		#
		# Defines a field on a subclass. This creates a getter and setter for the
		# name passed in. The options are used when building the administration forms.
		#
		# Regular dragonfly validations are available on :file and :image fields.
		# http://markevans.github.io/dragonfly/models#validations
		#
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

		# List fields
		#
		def self.fields
			@fields ||= Hash.new
		end

		# Return a constantized type, whitelisted by known subclasses.
		#
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
		def parents
			page, parents = self, Array.new
			while page.parent
				page = page.parent
				parents << page
			end
			parents
		end

		# Before validation hook.
		#
		# Build the path of the page to be used in routing.
		#
		def build_path
			_pages = self.parents.reverse + [self]
			self.path = "/#{_pages.map(&:slug).reject(&:blank?).join('/')}"
		end

		# Before validation hook
		#
		# All pages need to have a matching subdomain to parent page
		#
		def match_parent_subdomain
			return unless self.parent
			self.subdomain = self.parent.subdomain
		end

		def find_embedded_images
			text = self.fields.values.join(' ')
			matches = text.scan(/ei=([^&]*)/)
			encoded_ids = matches.map(&:first)
			ids = encoded_ids.map { |eid| Base64.urlsafe_decode64(URI.unescape(eid)) }
			EmbeddedImage.includes(:embeddable).find(ids)
		end

		def link_embedded_images!
			images = self.find_embedded_images
			images.each do |image|
				raise AlreadyLinkedEmbeddedImage if image.embeddable &&
					image.embeddable != self
				image.update!(embeddable: self)
			end
		end

		def layouts
			@layouts ||= Subdomain.new.layouts
		end

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

		def self.data_field(name)
			define_method(name) { fields[name.to_s] }
			define_method("#{name}=") { |val| fields[name.to_s] = val }
		end
  end
end

