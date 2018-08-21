class Admin::StaticController < ApplicationController

  skip_before_action :require_admin!
  skip_before_action :require_sysadmin!

  def dashboard
  end


end
