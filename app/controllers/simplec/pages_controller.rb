require_dependency "simplec/application_controller"
require_dependency "simplec/page_action_helpers"

module Simplec
  class PagesController < ApplicationController
    include Simplec::PageActionHelpers

    def show
      render_path params[:path] || ''
    end

  end
end
