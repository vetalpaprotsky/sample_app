class User < ActiveRecord::Base
	has_many :microposts, dependent: :destroy
  #before_save { self.email = self.email.downcase } # => те саме що і нижня стрічка
	before_save { email.downcase! } # => стовбець email має індекс..через це нам треба перевести
  # => сам емеїл в нижній регістир тому що не всі адаптери БД використовують регістрозалежні індекси
	before_create :create_remember_token

	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

	validates :name,  presence: true, length: { maximum: 50 }
	validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, 
																		uniqueness: { case_sensitive: false }
	validates :password, length: { minimum: 6 }
	has_secure_password

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def feed
    #те саме що і просто виклик методу microposts
    #id це метод
    Micropost.where("user_id = ?", id)
    #'user_id = ?' знак питання ставиться для захисту від SQL ін’єкції(Див. 10.3.3)
  end

  private

    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end
end