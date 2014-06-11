class SessionsController < ApplicationController

  def new
  end

  def create
    if auth.authenticate_and_log_in(params[:username], params[:password])
      redirect_to params[:next] || root_path
    else
      flash.now[:alert] = "Your username/password combination is not correct."
      render :new
    end
  end

  def destroy
    auth.log_out
    redirect_to root_path, status: 303
  end

end
