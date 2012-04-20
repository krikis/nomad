require 'spec_helper'

describe AnswersController do
  describe "GET index" do
    before { get :index }

    it "renders the 'answers' template" do
      response.should render_template("answers")
    end

    it "assigns the value true as @redirect" do
      assigns(:redirect).should be_true
    end
  end

  describe "GET new" do
    before { get :new }

    it "renders the 'answers' template" do
      response.should render_template("answers")
    end
  end

  describe "GET show" do
    before { get :show }

    it "renders the 'answers' template" do
      response.should render_template("answers")
    end
  end

  describe "GET edit" do
    before { get :edit }

    it "renders the 'answers' template" do
      response.should render_template("answers")
    end
  end

  describe "PUT sync" do

  end
end