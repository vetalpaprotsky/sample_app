require 'spec_helper'

describe User do
  
	before { @user = User.new(name: "Example User", email: "user@example.com", 
														password: "foobar", password_confirmation: "foobar") }

	subject { @user }

	it { should respond_to(:admin) }
	it { should respond_to(:microposts) }
	it { should respond_to(:name) }
	it { should respond_to(:email) }
	it { should respond_to(:password_digest) }
	it { should respond_to(:password) }
	it { should respond_to(:password_confirmation) }
	it { should respond_to(:remember_token) }
	it { should respond_to(:authenticate) }
  

	it { should be_valid }
  it { should_not be_admin }

  describe "with admin attributes set to 'true'" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end

    it { should be_admin }
  end

	describe "when name is not present" do
		before { @user.name = '' }
		it { should_not be_valid }
	end

	describe "when email is not present" do
		before { @user.email = '' }
		it { should_not be_valid }
	end

	describe "when name is too long" do 
		before { @user.name = "a" * 51 }
		it { should_not be_valid }
	end

	describe "when email format is invalid" do
		it "should be invalid" do
			addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com foo@bar..com]
      addresses.each do |invalid_address|
      	@user.email = invalid_address
      	expect(@user).not_to be_valid
      end
    end
	end

	describe "when email format is valid" do
		it "should be valid" do
			addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
			addresses.each do |valid_address|
				@user.email = valid_address
				expect(@user).to be_valid
			end
		end
	end

	describe "when email address is already taken" do
		before do
			user_with_same_email = @user.dup								# => cтворюємо копію і в ній емеїл робимо в верхньому регісті       <----\
			user_with_same_email.email = @user.email.upcase # => потім зберігаємо її в БД...так як емеїли не є регістрозалежні то    |
			user_with_same_email.save												# => FoO@bar.com == foo@bar.com...ми вже зберегли юзера з емеїлом USER@EXAMPLE.COM
		end																								# => тому @user не має бути валідний бо в нього емеїл user@example.com

		it { should_not be_valid }
	end

	describe "when password is not preset" do
		before do 
			@user = User.new(name: "Example User", email: "user@example.com", 
											 password: " ", password_confirmation: " ")
		end
		it { should_not be_valid }
	end

	describe "when password doesn't match confirmation" do
		before { @user.password_confirmation = "mismatch" }
		it { should be_invalid }
	end

	describe "with a password that's too short" do
		before { @user.password = @user.password_confirmation = "a" * 5 }
		it { should be_invalid }
	end

	describe "return value of authenticate method" do
		before { @user.save }
		let(:found_user) { User.find_by(email: @user.email) }

		describe "with valid password" do
			it { should eq found_user.authenticate(@user.password) }   # => 'eq' the save as '=='
		end

		describe "with invalid password" do
			let(:user_for_invalid_password) { found_user.authenticate("invalid") }

			it { should_not eq user_for_invalid_password }  
			specify { expect(user_for_invalid_password).to be_false } # => 'specify' the save as 'it' 
		end
	end

	describe "email address with mixed-case" do
		let(:mixed_case_email) { "Foo@EXampLe.cOm" }

		it "should be saved as all lover-case" do
			@user.email = mixed_case_email
			@user.save
			expect(@user.reload.email).to eq mixed_case_email.downcase
		end
	end

	describe "remember token" do
		before { @user.save }
		its(:remember_token) { should_not be_blank }
		#те саме що it { expect(@user.remember_token).not_to be_blank }
	end

	describe "micropost association" do

		before { @user.save }
		#let змінні ліниві(вони створюются коли до них звертаються)
		#let! змінні не ліниві(вони створються відразу) 
		let!(:older_micropost) do
			FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
		end
		let!(:newer_micropost) do
			#user: @user - вказує якому юзеру належить мікроповідомлення(Див. factories.rb) 
			#FactoryGirl позволяє змінити поле created_at (ActiveRecord не позволяє цього робити)
			FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
		end

		it "should have right the microposts in the right order" do
			expect(@user.microposts.to_a).to eq [newer_micropost, older_micropost]			
		end# => microposts треба переводити в масив(to_a)...по дефолту це collection proxy

		it "should destroy associated microposts" do
			#робимо копію мікропостів і зразу переводимо їх до масиву(за допомогою to_a)
			microposts = @user.microposts.to_a
			@user.destroy
			expect(microposts).not_to be_empty
			microposts.each do |micropost|
				#where верне nil якщо нічого не найде а find видасть exception
				expect(Micropost.where(id: micropost.id)).to be_empty
			end
		end
	end

end
