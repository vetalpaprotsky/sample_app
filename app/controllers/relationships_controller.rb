class RelationshipsController < ApplicationController
  before_action :non_signed_in_user

  #можна написати тільки 'respond_with @user' замість 'respond_to do |format|....end'
  #у двох екшинах і тут поза екшинами написати respond_to :html, :js
  #ефект такий самий

  def create
    @user = User.find(params[:relationship][:followed_id])
    current_user.follow!(@user)
    respond_to do |format|
      #якщо буде простий HTTP запрос то виконається redirect_to @user
      #а якщо буде Ajax запрос з JavaScript то виконається 
      #файл views/relationships/create.js.erb(назва файлу з назви екшину)
      format.html { redirect_to @user }
      format.js  
    end
  end

  def destroy
    #глянь в unfollow форму тому, що params[:id] це не є те id
    #яке є у стрічці браузера
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow!(@user)
    respond_to do |format|
      #так само якщо і з create тільки
      #файл views/relationships/destroy.js.erb
      format.html { redirect_to @user }
      format.js  
    end
  end
end