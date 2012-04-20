require 'spec_helper'

describe "Answers" do
  describe "GET /answers" do
    it "works!" do
      get answers_path
      response.status.should be(200)
    end
  end
end