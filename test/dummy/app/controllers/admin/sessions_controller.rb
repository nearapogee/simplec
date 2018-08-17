class Admin::SessionsController < ApplicationController

  skip_before_action :authenticate_user!, only: %w(new create)
  skip_before_action :require_admin!
  skip_before_action :require_sysadmin!

  def new
    @pages = Simplec::Admin::Page.all
    if current_user
      redirect_to admin_root_url
      return
    end
  end

  def create
    @pages = Simplec::Admin::Page.all
    @user = User.find_by(email: params[:email].to_s.strip.downcase)

    if @user && @user.authenticate(params[:password])
      sign_in! @user
      redirect_to admin_root_url
    else
      render :new
    end
  end

  def destroy
    @pages = Simplec::Admin::Page.all
    sign_out!
    redirect_to simplec.root_url(subdomain: 'www')
  end

end
