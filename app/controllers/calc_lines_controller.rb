class CalcLinesController < ApplicationController
  def home
  end
  
  def calc
    if params[:plan] == "free"
    elsif params[:plan] == "light"
    elsif params[:plan] == "standard"
    end
  end
  
  private
  
  def calc_free_plan(traffic)
  end
  
  def calc_light_plan(traffic)
  end
  
  def calc_standard_plan(traffic)
  end
end
