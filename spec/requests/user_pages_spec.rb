require 'spec_helper'

describe "User pages" do

	subject { page } # => page це Capybara змінна яка вказує на стрінку на якій ми перебуваємо

	describe "index" do
		before(:each) do  # => before(:each) == before(перед кожним тестом буде спрацьовував переданий блок)
			sign_in FactoryGirl.create(:user)
			FactoryGirl.create(:user, name: "Bob", email: "bob@example.com")
			FactoryGirl.create(:user, name: "Ben", email: "ben@example.com")
			visit users_path
		end

		it { should have_title('All users') }
		it { should have_content('All users') }

		describe "pagination" do
			# => before(:all) переданий йому блок спрацює 1 раз перед всіма тестами в блоці
			before(:all) { 30.times { FactoryGirl.create(:user) } }
			after(:all)  { User.delete_all }

			it { should have_selector('div.pagination') }

			it "should list each user" do
				User.paginate(page: 1).each do |user|
					expect(page).to have_selector('li', text: user.name)
				end
			end
		end 
		#it "should list each user" do # => тест без пагінації
		#   User.all.each do |user|
		#       expect(page).to have_selector('li', text: user.name)
		#   end
		#end

		describe "delete links" do
			
			it { should_not have_link("delete") }

			describe "as an admin user" do
				let(:admin) { FactoryGirl.create(:admin) }
				before do
					sign_in admin
					visit users_path
				end
				# => силка видалення така сама як на вхід  \/...але там метод delete замість get
				# => перший юзер в бд буде той створенний  | в самому верху ст.9
				# => тому   силка   на  його   видалення в |  All users має бути
				it { should have_link('delete', href: user_path(User.first)) }
				it "should be able to delete another user" do
					expect { click_link('delete', match: :first) }.to change(User, :count).by(-1)
				end														 #/\першу силку яку знайде
				it { should_not have_link('delete', href: user_path(admin)) } # => сам себе не має видаляти
			end															
		end
	end

	describe "profile page" do
		let(:user) { FactoryGirl.create(:user) }
		let!(:m1) { FactoryGirl.create(:micropost, user: user, content: "Foo") }
		let!(:m2) { FactoryGirl.create(:micropost, user: user, content: "Bar") }

		before { visit user_path(user) }

		it { should have_content(user.name) }
		it { should have_title(user.name) }

		describe "microposts" do
			it "quantity should equal 2" do
				expect(user.microposts.count).to eq 2
			end
			it { should have_content("Microposts(#{user.microposts.count})") }
			it { should have_content(m1.content) }
			it { should have_content(m2.content) }
			it { should_not have_link('delete') }

      describe "for signed-in user" do
        before { sign_in user }
        it "should have delete links" do
          user.microposts.each do |micropost|
            expect(page).to have_link('delete', href: micropost_path(micropost))
          end
        end 
      end

      it "pagination" do
      	30.times { |n| FactoryGirl.create(:micropost, user: user, content: "Lorem#{n}") }
        visit current_path
        expect(page).to have_selector('div.pagination')
        user.microposts.paginate(page: 1).each do |micropost|
        	expect(page).to have_selector("li span.content", text: micropost.content)
        end
      end
		end
	end

	describe "signup page" do 
		before { visit signup_path }

		it { should have_content 'Sign up' }
		it { should have_title full_title('Sign up') }
	end

	describe "signup page" do
		before{ visit signup_path } # => visit це Capybara функція
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
  		fill_in "Name",         with: "Example User" # => fill_in це Capybara функція
  		fill_in "Email",        with: "user@example.com"
  		fill_in "Password",     with: "foobar"
  		fill_in "Confirmation", with: "foobar"
	  end

	  it "should create a user" do
		  expect { click_button submit }.to change(User, :count).by(1)
	  end

	  describe "after submission" do
  		before { click_button submit }
  		let(:user) { User.find_by(email: "user@example.com") }

  		it { should have_title(user.name) }
  		it { should have_selector('div.alert.alert-success', text: 'Welcome') }
  		it { should have_selector('h1', text: "Example User") }
  	 end

  	 describe "after saving the user" do
  		before { click_button submit }
  		let(:user) { User.find_by(email: 'user@example.com') }

  		it { should have_link('Sign out') }
  		it { should have_title(user.name) }
  		it { should have_selector('div.alert.alert-success', text: 'Welcome') }
  	  end
		end
	end

	describe "edit" do
		let(:user) { FactoryGirl.create(:user) }
		before do 
			sign_in user #в spec/support/utilities.rb
			visit edit_user_path(user) 
		end

		describe "page" do
			it { should have_content "Update your profile" }
			it { should have_title "Edit user" }
			it { should have_link "change", href: "http://gravatar.com/emails" }
		end

		describe "with invalid information" do
			before { click_button "Save changes" }

			it { should have_content "error" }
		end

		describe "with valid information" do
			let(:new_name) { "New Name" }
			let(:new_email) { "new@example.com" }
			before do
				fill_in "Name",               with: new_name
				fill_in "Email",              with: new_email
				fill_in "Password",         with: user.password
				fill_in "Confirmation", with: user.password_confirmation
				click_button "Save changes"
			end

			it { should have_title(new_name) }
			it { should have_selector('div.alert.alert-success') }
			it { should have_link('Sign out', href: signout_path) }
			specify { expect(user.reload.name).to eq new_name }
			specify { expect(user.reload.email).to eq new_email }
		end

		describe "fobidden attributes" do
			let(:params) do
				{ user: { admin: true, password: user.password, 
					        password_confirmation: user.password } }
			end
			before do
				sign_in user, no_capybara: true
				patch user_path(user), params
			end
			specify { expect(user.reload).not_to be_admin }
		end
	end

end