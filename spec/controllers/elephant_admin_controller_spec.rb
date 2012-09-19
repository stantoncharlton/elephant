require 'spec_helper'

describe ElephantAdminController do

  describe "GET 'show'" do
    it "returns http success" do
      get 'show'
      response.should be_success
    end
  end

  describe "GET 'new_company'" do
    it "returns http success" do
      get 'new_company'
      response.should be_success
    end
  end

  describe "GET 'new_user'" do
    it "returns http success" do
      get 'new_user'
      response.should be_success
    end
  end

end
