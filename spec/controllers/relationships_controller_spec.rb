require 'spec_helper'

describe RelationshipsController do
  
  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }

  before { sign_in user, no_capybara: true }

  describe "creating a relationship with Ajax" do

    it "should increment the Relatioship count" do
      expect do
        #HTTP запрос, екшин, інформація в params
        #у нас в params буде хеш relationship з ключем followed_id рівним other_user.id
        xhr :post, :create, relationship: { followed_id: other_user.id }
      end.to change(Relationship, :count).by(1)
    end

    it "should respond with success" do
      xhr :post, :create, relationship: { followed_id: other_user.id }
      expect(response).to be_success
    end
  end 

  describe "destroying  relationship with Ajax" do

    before { user.follow!(other_user) }
    let(:relationship) { user.relationships.find_by(followed_id: other_user.id) }

    it "should decrement the Relationship count" do
      expect do
        xhr :delete, :destroy, id: relationship.id
      end.to change(Relationship, :count).by(-1)
    end
    
    it "should respond to success" do
      xhr :delete, :destroy, id: relationship.id
      expect(response).to be_success
    end
  end

end