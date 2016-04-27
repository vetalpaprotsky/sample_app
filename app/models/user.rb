class User < ActiveRecord::Base
	before_save { self.email = email.downcase } # => стовбець email має індекс..через це нам треба перевести
  # => сам емеїл в нижній регістир тому що не всі адаптери БД використовують регістрозалежні індекси
	validates :name,  presence: true, length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
					  uniqueness: { case_sensitive: false }

	validates :password, length: { minimum: 6 }
	has_secure_password
end