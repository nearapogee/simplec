module Simplec
  class ApplicationController < ::ActionController::Base
    protect_from_forgery with: :exception

    after_action do
      Thread.current[:simplec_subdomain] = nil
    end
  end
end
