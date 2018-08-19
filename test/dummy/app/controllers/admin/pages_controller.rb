class Admin::PagesController < ApplicationController

  skip_before_action :require_admin!,
    only: %w(index edit update) # users can update, but not create or destroy
  skip_before_action :require_sysadmin!

  def index
    @pages = Simplec::Admin::Page.includes(:subdomain).
      order("simplec_subdomains.name ASC, simplec_pages.path ASC")
  end

  def new
    @page = Simplec::Page.type(params[:type] || "TODO list dir contents").new
  end

  def create
    @page = Simplec::Page.type(params[:page][:type]).new(page_params)

    if @page.save
      redirect_to edit_admin_page_url(@page)
    else
      render :new
    end

  end

  def edit
    @page = Simplec::Page.find(params[:id])

    # if @page.save
    #   redirect_to admin_pages_path(@page)
    # else
    #   render plain: "file not saved"
    # end

  end

  def update
    @page = Simplec::Page.find(params[:id])

    if @page.update(page_params)
      redirect_to edit_admin_page_url(@page)
    else
      render :edit
    end
  end

  def destroy
    @page = Simplec::Page.find(params[:id])
    if @page.destroy
      redirect_to admin_pages_url
    else
      render :edit
    end
  end

  private

  def page_params
    cls = Simplec::Page.type(params[:page][:type])
    attributes = [
      :type, :subdomain_id, :parent_id, :slug,
      :title, :meta_description, :layout
    ] +
			cls.field_names +
			cls.field_names(:file).inject(Array.new) {|memo, name|
				memo << :"remove_#{name}"
				memo << :"retained_#{name}"
				memo
			}
    attributes += [permissible_user_ids: []] if current_user.admin? ||
      current_user.sysadmin?

    params.require(:page).permit(*attributes)
  end

end
