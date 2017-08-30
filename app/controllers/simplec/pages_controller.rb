require_dependency "simplec/application_controller"
require_dependency "simplec/page_action_helpers"

module Simplec
  class PagesController < ApplicationController

    def show
      begin
        render_path params[:path] || ''
      rescue ActiveRecord::SubclassNotFound => e
        # TODO add proc config for error notification, airbrake, etc
        #
        Rails.logger.info e
        render status: 404
      end
    end

  end
end
