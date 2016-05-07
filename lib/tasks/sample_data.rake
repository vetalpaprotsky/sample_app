namespace :db do
	desc "Fill databse with sample data"
	task populate: :environment do
		User.create!(name:     "Example user",
					       email:    "exapmle@railstutorial.org",
					       password: "foobar",
					       password_confirmation: "foobar",
					       admin: true)
		99.times do |n|
			name =     Faker::Name.name
			email =    "exapmle-#{n+1}@railstutorial.org"
			password = "password"
			User.create!(name:     name, 
				           email:    email, 
				           password: password,
				           password_confirmation: password)
		end
	end
end # => тут ми створили нову rake задачу rake db:populate яка створює 100 фейкових користувачів