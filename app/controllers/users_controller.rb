class UsersController < ApplicationController
  before_action :non_signed_in_user, only: [:edit, :update, :index, :destroy]
  before_action :signed_in_user,     only: [:new, :create]
  before_action :correct_user,       only: [:edit, :update]
  before_action :admin_user,         only: :destroy

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
  	@user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def new
  	@user = User.new
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def create
  	@user = User.new(user_params)
  	if @user.save
      sign_in @user
  		flash[:success] = "Welcome to Sample App!"	# => ДИВ. 7.3.2 ФЛЕШ
  		redirect_to @user # => те саме що і 'redirect_to user_path(@user)'
  	else
  		render 'new'
  	end
  end

  def destroy
    @user = User.find(params[:id])
    if current_user == @user
      redirect_to root_url 
      return
    end
    @user.destroy
    flash[:success] = "User deleted."
    redirect_to users_url
  end

  def following
    @title = 'Following'
    @user = User.find(params[:id])
    @users = @user.followed_users.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = 'Followers'
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  private

  def user_params
  	params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  # => notice: "Please sign in." - те саме що і flash[:notice] = "Please sign in."
  # => але тут redirect_to приймає notice як параметр, а з flash нам потрібно писати окрему стрічку коду
  def signed_in_user
    redirect_to root_url unless current_user.nil?
  end

  def correct_user
    @user = User.find(params[:id]) 
    redirect_to(root_url) unless current_user?(@user)
  end

  def admin_user
    redirect_to root_url unless current_user.admin?
  end
end
