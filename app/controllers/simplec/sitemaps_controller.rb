require_dependency "simplec/application_controller"

module Simplec
  class SitemapsController < ApplicationController

    def show
      @pages = Page.includes(:subdomain)
    end
  end
end
