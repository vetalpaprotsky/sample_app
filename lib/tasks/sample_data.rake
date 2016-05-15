namespace :db do
	desc "Fill databse with sample data"
	task populate: :environment do
		make_users
		make_microposts
		make_relationships
	end
end # => тут ми створили нову rake задачу rake db:populate яка створює 100 фейкових користувачів

def make_users
	admin = User.create!(name:     "Example user",
								       email:    "exapmle@railstutorial.org",
								       password: "foobar",
								       password_confirmation: "foobar",
								       admin: true)
	99.times do |n|
		name = Faker::Name.name
		email = "exapmle-#{n+1}@railstutorial.org"
		password = "password"
		User.create!(name:     name, 
			           email:    email, 
			           password: password,
			           password_confirmation: password)
	end
end

def make_microposts
	users = User.all(limit: 6)
	50.times do
		#Faker::Lorem.sentence(n) створює рандомні речення
		content = Faker::Lorem.sentence(5)
		users.each { |user| user.microposts.create!(content: content) }
	end
end

def make_relationships
	users = User.all
	user = users.first
	followed_users = users[2..50]
	followers      = users[3..40]
	followed_users.each { |followed| user.follow!(followed) }
	followers.each      { |follower| follower.follow!(user) }
end