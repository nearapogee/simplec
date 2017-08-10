module Simplec
  class Subdomain < ApplicationRecord
		has_many :pages
		has_and_belongs_to_many :document_sets
		has_and_belongs_to_many :documents

		validates :name,
			presence: true,
			exclusion: { in: %w(admin) }
		validates :default_layout,
			inclusion: {in: :layouts, allow_blank: true}

		def layouts
			@layouts ||= Dir[Rails.root.join('app/views/layouts').to_s + "/*.html.*"].
				map{|n| File.basename(n).split('.', 2).first }.
				reject{|n| n =~ /\A_/ || n =~ /mailer/ || n =~ /application/ || n =~ /sessions/}.
				sort
		end

		module Normalizers

			# Force lowercase name
			#
			def name=(val)
				super (val ? val.to_s.strip.downcase : val)
			end
		end
		prepend Normalizers
  end
end
