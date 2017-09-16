require "simplec/engine"
require "simplec/embedded_image_actions"
require 'simplec/action_controller/extensions'
require 'simplec/action_view/helper'
require "simplec/page_action_helpers"


# Configuration details will go here.
#
# @!visibility public
module Simplec

  # Get application view helpers.
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
