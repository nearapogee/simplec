require_dependency "simplec/application_controller"

module Simplec
  class PagesController < ApplicationController

    def show
      @page = page("/#{params[:path]}")
      render layout: layout(@page)
    end

    private

    def layout(page)
      [page.layout, page.subdomain.default_layout, 'public']. # TODO allow config for public
        reject(&:blank?).first
    end

  end
end
