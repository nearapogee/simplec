class Admin::DocumentsController < ApplicationController

  skip_before_action :require_sysadmin!
  skip_before_action :require_admin!

  def index
    @document_set = Simplec::DocumentSet.find_by(id: params[:document_set_id])
    @documents = Simplec::Document.order(name: :asc).
      filter_document_set(@document_set) # see test/dummy/config/initializers/simplec.rb
  end

  def new
    @document = Simplec::Document.new
  end

  def create
    @document = Simplec::Document.new(document_params)

    if @document.save
      redirect_to edit_admin_document_url(@document)
    else
      render :new
    end
  end

  def edit
    @document = Simplec::Document.find(params[:id])
  end

  def update
    @document = Simplec::Document.find(params[:id])

    if @document.update(document_params(@document))
      redirect_to edit_admin_document_url(@document)
    else
      render :edit
    end
  end

  def destroy
    @document = Simplec::Document.find(params[:id])

    if current_user.sysadmin? || !@document.required?
      @document.destroy!
      redirect_to documents_url
    else
      redirect_to edit_document_url(@document)
    end
  end

  private

  def document_params(document=nil)
    attrs = [
      :name, :description,
      :file, :removed_file, :retained_file
    ]
    attrs += [
      :document_set_id,
      subdomain_ids: []
    ] if current_user.sysadmin? || document.nil? || !document.required?
    attrs += [
      :slug, :required
    ] if current_user.sysadmin?
    params.require(:document).permit(attrs)
  end

end
