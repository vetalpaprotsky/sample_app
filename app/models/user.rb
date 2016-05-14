class User < ActiveRecord::Base
	has_many :microposts, dependent: :destroy
  #У цьому випадку нам потрібно вказувати іноземний ключ follower_id
  #з мікропостами ми цього не писали тому, що у них є поле user_id
  #і Rails сам розуміє що це іноземний ключ для User.А у relationships
  #просто не може бути поля user_id. Там є follower_id - той хто слідкує(читає)
  #і followed_id - той за ким слідкують(читаючий)
  #
  #Метод relationships буде заходити в таблицю relationships і витягувати усі поля
  #в яких follower_id буде рівне id даного юзера
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  #Створює масив користувачів за якими слідкує даний юзер(followed_users - вертає масив)
  #в таблиці relationships шукає поля в який follower_id рівний
  #id даного юзера.Потім з цих полів береться followed_id(тобто id користувача 
  #за яким слідкує даний юзер) і по них витягуються користувачів
  #
  #source: :followed каже що по полі followed_id будем витягувати користувачів
  has_many :followed_users, through: :relationships, source: :followed
  #Також вказуємо іноземний ключ
  #
  #тут наоборот метод reverse_relationships буде заходити в таблицю relationships і витягувати усі поля
  #в яких followed_id буде рівне id даного юзера
  has_many :reverse_relationships, foreign_key: "followed_id", 
                                   #вказуєм ім’я класу щоб Rails не шукав не існуючий клас
                                   class_name:  "Relationship",
                                   dependent:   :destroy
  #Тут наоборот вертає масив користувачів які слідкують за даним юзером(followers - вертає масив)
  #source: :follower можна опустити бо назва масиву така сама тільки в множині(followers)
  has_many :followers, through: :reverse_relationships, source: :follower
  #before_save { self.email = self.email.downcase } те саме що і нижня стрічка
	#стовбець email має індекс..через це нам треба перевести
  #сам емеїл в нижній регістир тому що не всі адаптери БД використовують регістрозалежні індекси
  before_save { email.downcase! }
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
    #id це метод(self.id писати не обов’язково)
    #'user_id = ?' знак питання ставиться для захисту від SQL ін’єкції(Див. 10.3.3)
    Micropost.where("user_id = ?", id)
  end

  def following?(other_user)
    #self.  писати не обов’язково
    relationships.find_by(followed_id: other_user.id) ? true : false
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    relationships.find_by(followed_id: other_user.id).destroy!
  end

  private

    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end
end