require_dependency "simplec/application_controller"

module Simplec
  class EmbeddedImagesController < ApplicationController
    include Simplec::EmbeddedImageActions
  end
end
