require 'nokogiri'

module Simplec
  class NokogiriBuilder
    class_attribute :default_format
    self.default_format = Mime[:xml]

    def self.call(template)
      "xml = ::Nokogiri::XML::Builder.new(encoding: 'UTF-8') { |xml| #{template.source} }.to_xml;"
    end
  end
end

ActionView::Template.register_template_handler :nokogiri, Simplec::NokogiriBuilder
