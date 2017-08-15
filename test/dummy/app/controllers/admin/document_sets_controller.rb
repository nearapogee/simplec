class Admin::DocumentSetsController < ApplicationController

  skip_before_action :require_sysadmin!
  skip_before_action :require_admin!

  def index
    @document_sets = Simplec::DocumentSet.order(name: :asc)
    @active_link = 'documents'
  end

  def new
    @document_set = Simplec::DocumentSet.new
    @active_link = 'documents'
  end

  def create
    @document_set = Simplec::DocumentSet.new(document_set_params)

    if @document_set.save
      redirect_to edit_admin_document_set_url(@document_set)
    else
      render :new
    end
  end

  def edit
    @document_set = Simplec::DocumentSet.find(params[:id])
  end

  def update
    @document_set = Simplec::DocumentSet.find(params[:id])

    if @document_set.update(document_set_params(@document_set))
      redirect_to edit_admin_document_set_url(@document_set)
    else
      render :edit
    end
  end

  def destroy
    @document_set = Simplec::DocumentSet.find(params[:id])

    if current_user.sysadmin? || !@document_set.required?
      @document_set.destroy!
      redirect_to document_sets_url
    else
      redirect_to edit_admin_document_set_url(@document_set)
    end
  end

  private

  def document_set_params(document_set=nil)
    attrs = [ :name, :description ]
    attrs += [
      subdomain_ids: []
    ] if current_user.sysadmin? || document_set.nil? || !document_set.required?
    attrs += [
      :slug, :required
    ] if current_user.sysadmin?
    params.require(:document_set).permit(attrs)
  end
end
