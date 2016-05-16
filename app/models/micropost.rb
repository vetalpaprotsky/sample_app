class Micropost < ActiveRecord::Base
	belongs_to :user
	#Для того щоб порядок мікроповідомлень в БД був спадаючий відносно їхньої дати створення
	default_scope -> { order('created_at DESC') }
	validates :content, presence: true, length: { maximum: 140 }
	validates :user_id, presence: true

  def self.from_users_followed_by(user)
    #метод followed_user_ids еквівалентний followed_user.map { |user| user.id }
    #або followed_user.map(&:id), тобто він вертає масив айдішок юзерів 
    #яких читає даний юзер.
    #там де є знаки питання там будуть вставлятися елементи після коми відповідно
    #ми вставляємо масив який вертає followed_user_ids замість (?) (SQL сам робить інтерполяцію стрічки).
    #followed_user_ids метод який rails надав при асоціації has_many
    
    #followed_user_ids = user.followed_user_ids
    #where("user_id IN (?) OR user_id = ?", followed_user_ids, user.id)
    
    #where = тут працює як Micropost.where
    #тому, що ми в методі класу.
    #"user_id IN (?) OR user_id = ?" - вибери усі мікроповідомлення
    #в яких user_id рівним любому елементу В followed_user_ids або рівний user.id

    #кращий спосіб вибрати мікроповідомлення
    #тут використовується інший спосіб вставки user.id 
    followed_user_ids = "SELECT followed_id FROM relationships
                         WHERE follower_id = :user_id" #<--
    where("user_id IN (#{followed_user_ids}) OR user_id = :user_id", #<-- 
          user_id: user.id)
  end
end
