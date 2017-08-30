# @!visibility private
module Simplec
  class ApplicationController < ::ActionController::Base
    include Simplec::ActionController::Extensions
    include Simplec::PageActionHelpers

    protect_from_forgery with: :exception

    after_action do
      Thread.current[:simplec_subdomain] = nil
    end
  end
end
