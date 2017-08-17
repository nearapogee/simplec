class MessagesController < ApplicationController
  include Simplec::PageActionHelpers

  skip_before_action :authenticate_user!
  skip_before_action :require_admin!
  skip_before_action :require_sysadmin!

  def create
    @message = Message.new(message_params)

    if @message.save
      flash[:notice] = "Message sent."
      redirect_to simplec_url_for('contact')
    else
      flash.now[:error] = "Please fix your form inputs."
      render_path 'contact'
    end
  end

  private

  def message_params
    params.require(:message).permit(:email, :body)
  end

end
