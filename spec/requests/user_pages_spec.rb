require 'spec_helper'

describe "User pages" do

	subject { page } # => page це Capybara змінна яка вказує на стрінку на якій ми перебуваємо

	describe "profile page" do
		let(:user) { FactoryGirl.create(:user) }
		before { visit user_path(user) }

		it { should have_content(user.name) }
		it { should have_title(user.name) }
	end

	describe "signup page" do 
		before { visit signup_path }

		it { should have_content 'Sign up' }
		it { should have_title full_title('Sign up') }
	end

	describe "signup page" do
		before{ visit signup_path }	# => visit це Capybara функція
		let(:submit) { "Create my account" }

		describe "with invalid information" do
			it "should not create a user" do
			 	expect { click_button submit }.not_to change(User, :count)  # => click_button це Capybara функція
			 	#одна верхня стрічка замінює чотири нижні стрічки
			 	#initial = User.count
				#click_button "Create my account"
				#final = User.count
				#expect(initial).to eq final
			end
			describe "after submission" do
				before { click_button submit }

				it { should have_title "Sign up" }
				it { should have_content "error" }
				it { should have_content "Name can't be blank" }
				it { should have_content "Email can't be blank" }
				it { should have_content "Email is invalid" }
				it { should have_content "Password is too short (minimum is 6 characters)" }
				it { should have_content "Password can't be blank" }
			end
		end

    describe "with valid information" do
      before do
        fill_in "Name",         with: "Example User"     # => fill_in це Capybara функція
        fill_in "Email",        with: "user@example.com"
        fill_in "Password",     with: "foobar"
        fill_in "Confirmation", with: "foobar"
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after submission" do
      	before { click_button submit }
      	let(:user) { User.find_by(email: 'user@example.com') }

      	it { should have_title(user.name) }
      	it { should have_selector('div.alert.alert-success', text: 'Welcome') }
      	it { should have_selector('h1', text: "Example User") }
      end
		end
	end

end
