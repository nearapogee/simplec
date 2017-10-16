require "simplec/engine"
require "simplec/embedded_image_actions"
require 'simplec/action_controller/extensions'
require 'simplec/action_view/helper'
require "simplec/page_action_helpers"
require "simplec/nokogiri_builder"


# Configuration details will go here.
#
# @!visibility public
module Simplec

  # Get application view helpers.
  #
  # @note
  #   A copy of ApplicationHelper has been removed from the module tree but is still active!
  #
  #   If that occurs it is because the Module has been changed but app needs to
  #   be restarted because they are loaded at initialize. require_dependency
  #   might be able to fix it.
  #
  # @example append helper
  #   Simplec.helpers << ::ApplicationHelper
  #
  # @return [Array]
  #   of view helpers
  def self.helpers
    @helpers ||= Array.new
  end

  # Set the helpers to be included.
  #
  # @example set a single helper
  #   Simplec.helpers = ::ApplicationHelper
  #
  # @example append helpers
  #   Simplec.helpers += [::ApplicationHelper]
  #
  # @param helpers [Array, Class]
  #   either a single helper or an array of helpers
  def self.helpers=(helpers)
    @helpers = Array(helpers)
  end
end
