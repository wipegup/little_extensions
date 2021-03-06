class UsersController < ApplicationController
  before_action :require_user, except: [:new, :create]
  
  def show
    @user = current_user
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if user_info[:password] == ""
      @user.update(user_info.except(:password, :password_confirmation))
    elsif user_info[:password]
      @user.update(user_info)
    end
    if @user.save
      flash[:notice] = "You have updated your information."
      redirect_to profile_path
    else
      render :edit
    end
  end

  def create

    @user = User.new(user_info)

    if @user.valid?
      @user.save

      flash[:info] = "You are now registered and logged in"
      session[:user_id] = @user.id.to_s
      redirect_to profile_path
    else
      render :new
    end
  end

  def new
    unless current_visitor?
      flash[:info] = "You are already registered"
      redirect_to root_path
    end
    @user = User.new
  end

  private

  def user_info
    params
    .require(:user)
    .permit(:name, :street_address, :city, :state, :zip_code, :email,
      :password, :password_confirmation)
  end

  def require_user
    render_404 unless current_user?
  end

end
