require 'spec_helper'

describe "answers/answers" do

  it "contains a div with the 'answers' id" do
    render
    assert_select "div[id=?]", "answers"
  end
end