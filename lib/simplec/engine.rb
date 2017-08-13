require 'simplec/action_controller/extensions'
require 'simplec/action_view/helper'

module Simplec
  class Engine < ::Rails::Engine
    isolate_namespace Simplec

    initializer "simplec_controller_extensions" do
      ActiveSupport.on_load(:action_controller_base) {
        prepend Simplec::ActionController::Extensions
        helper Simplec::ActionView::Helper
      }
      ActiveSupport.on_load(:active_record) {
        Dir["#{Rails.root}/app/models/page/*.rb"].each {|file| require_dependency file }
      }
    end
  end
end
