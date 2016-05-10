class Micropost < ActiveRecord::Base
	belongs_to :user
	#Для того щоб порядок мікроповідомлень в БД був спадаючий відносно їхньої дати створення
	default_scope -> { order('created_at DESC') }
	validates :content, presence: true, length: { maximum: 140 }
	validates :user_id, presence: true
end
