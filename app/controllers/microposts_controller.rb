class MicropostsController < ApplicationController
  before_action :non_signed_in_user
  before_action :correct_user, only: :destroy

  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost.destroy
    redirect_to(:back)
    #в книжці пише redirect_to root_url, але ми можемо видалити повідомлення
    #і зі стронки profile, для чого потім перекидати користувача на головну стрінку
    #було б краще залишити його там де він був...і наприклад якщо він видаляв на
    #третій стронці повідомлень, то його і на ній залише завдяки redirect_to(:back)
  end

  private

    def micropost_params
      params.require(:micropost).permit(:content)
    end

    #На сторінках home і profile ми вже робимо провірку чи мікроповідомлення
    #належить даному користувачу...якщо так то ми виводимо силку delete на видалення,
    #якщо ні то нічого не виводимо...Тобто це проста провірка чи виводити delete 
    #Для чого тоді нам в контроллері Microposts в екшині
    #destroy ще раз провіряти чи це повідомлення належить даному юзеру?
    #Тому, що є можливість відправити delete запрос в браузер і видалити чуже повідомлення.
    #Ми повинні також провіряти тут
    def correct_user
      @micropost = current_user.microposts.find(params[:id])#просто find шукає по id
    rescue
      redirect_to root_url      
    end
end