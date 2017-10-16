require 'test_helper'

module Simplec
  class SitemapsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    def test_show
      get "/sitemap.xml"
      assert_response 200
    end
  end
end
