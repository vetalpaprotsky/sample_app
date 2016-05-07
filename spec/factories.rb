FactoryGirl.define do
	factory :user do
		sequence(:name)  { |n| "Person_#{n}" }
		sequence(:email) { |n| "person_#{n}@example.com" }
		password "foobar"
		password_confirmation "foobar"

		factory :admin do
			admin true
		end
	end
end# => а тут кожне ствроння об’єкту буде ітерувати 'n'

=begin # => зажди буде створювати один і той самий об’єкт
FactoryGirl.define do
	factory :user do
		name	"Michael Hartl"
		email "michael@example.com"
		password "foobar"
		password_confirmation "foobar"
	end
end
=end