class CalcLinesController < ApplicationController
  ### 定数宣言部
  FREE_PLAN_MONTH = 0
  LIGHT_PLAN_MONTH = 5000
  STANDARD_PLAN_MONTH = 15000
  
  FREE_PLAN_FREE_TRF = 1000
  LIGHT_PLAN_FREE_TRF = 15000
  STANDARD_PLAN_FREE_TRF = 45000
  
  LIGHT_PLAN_FEE_PER_TRF = 5
  STANDARD_PLAN_FEE_PER_TRF = [
    [ 3.00, 50000 ],
    [ 2.80, 50000 ],
    [ 2.60, 100000 ],
    [ 2.40, 100000 ],
    [ 2.20, 100000 ],
    [ 2.00, 100000 ],
    [ 1.90, 100000 ],
    [ 1.80, 100000 ],
    [ 1.70, 100000 ],
    [ 1.60, 100000 ],
    [ 1.50, 100000 ]
    ]
  
  def home
    @line_histories = LineHistory.where(month: 1..12)
  end
  
  def calc
    if params[:plan] == "free"
      @fee = calc_free_plan(params[:traffic])
    elsif params[:plan] == "light"
      @fee = calc_light_plan(params[:traffic])
    elsif params[:plan] == "standard"
      @fee = calc_standard_plan(params[:traffic])
    else
      # :planに想定外の値が入ってきた場合は固定で-1
      @fee = -1
    end
    
    @line_history = LineHistory.find_by(month: params[:month])
    @line_history.update_attributes(fee: @fee, traffice: params[:traffic])
    
    @line_histories = LineHistory.where(month: 1..12)
  end
  
  private
  
  # フリープランの料金計算(無料分を超えた場合はエラー)
  def calc_free_plan(traffic)
    if traffic > FREE_PLAN_FREE_TRF
      fee = -1
    else
      fee = FREE_PLAN_MONTH
    end
    
    return fee
  end
  
  def calc_light_plan(traffic)
    fee = LIGHT_PLAN_MONTH
    
    temp_trf = traffic - LIGHT_PLAN_FREE_TRF
    
    if temp_trf > 0
      fee += temp_trf * LIGHT_PLAN_FEE_PER_TRF
    end
    
    return fee
  end
  
  def calc_standard_plan(traffic)
    fee = STANDARD_PLAN_MONTH
    
    # 無料通信分を計算
    temp_trf = traffice - STANDARD_PLAN_FREE_TRF
    
    # 無料通信分以内であれば、追加なし
    return fee if temp_trf <= 0
    
    # 追加料金計算
    STANDARD_PLAN_FEE_PER_TRF.each do |one_fee|
      if temp_trf > one_fee[0]
        fee += one_fee[0] * one_fee[1]
        temp_trf -= one_fee[0]
      else
        fee += temp_trf * one_fee[1]
        break
      end
    end
    
    return fee
  end
end
