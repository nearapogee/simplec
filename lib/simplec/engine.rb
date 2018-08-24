module Simplec
  class Engine < ::Rails::Engine
    isolate_namespace Simplec

    initializer "simplec_controller_extensions" do
      ActiveSupport.on_load(:action_controller_base) {
        include Simplec::ActionController::Extensions
        prepend Simplec::PageActionHelpers
        helper Simplec::ActionView::Helper
        helper *Simplec.helpers
      }
      # Not required anymore, keep in Page Model in host application
      # ActiveSupport.on_load(:active_record) { Simplec.load_pages }
    end
  end

  def self.load_pages
    Dir["#{Rails.root}/app/models/page/*.rb"].
      each {|file| require_dependency file }
  end
end
