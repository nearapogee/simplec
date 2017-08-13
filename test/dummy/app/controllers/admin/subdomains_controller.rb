class Admin::SubdomainsController < ApplicationController
  skip_before_action :require_sysadmin!

  def index
    @subdomains = Simplec::Subdomain.order(name: :asc)
  end

  def new
    @subdomain = Simplec::Subdomain.new
  end

  def create
    @subdomain = Simplec::Subdomain.new(subdomain_params)

    if @subdomain.save
      redirect_to edit_admin_subdomain_url(@subdomain)
    else
      render :new
    end
  end

  def edit
    @subdomain = Simplec::Subdomain.find(params[:id])
  end

  def update
    @subdomain = Simplec::Subdomain.find(params[:id])

    if @subdomain.update(subdomain_params)
      redirect_to edit_admin_subdomain_url(@subdomain)
    else
      render :edit
    end
  end

  def destroy
    @subdomain = Simplec::Subdomain.find(params[:id])
    @subdomain.destroy!
  end

  private

  def subdomain_params
    params.require(:_subdomain).permit(
      :name, :description, :default_layout
    )
  end
end
