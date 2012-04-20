class AnswersController < ApplicationController

  def index
    @redirect = true
    render :action => 'answers'
  end

  def new
    render :action => 'answers'
  end

  def show
    render :action => 'answers'
  end

  def edit
    render :action => 'answers'
  end
end