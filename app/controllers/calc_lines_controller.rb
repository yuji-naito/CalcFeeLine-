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
    # 1～12月分を昇順に取得
    @line_histories = LineHistory.where(month: 1..12).order(month: :asc)
    @current_line = LineHistory.new
  end
  
  def calc
    line_data = line_history_params
    
    # プランによって料金を計算する
    if line_data[:plan] == "free"
      @fee = calc_free_plan(line_data[:traffic].to_i)
      if @fee == -1
        flash[:notice] = "フリープランは1000通までです。"
      end
    elsif line_data[:plan] == "light"
      @fee = calc_light_plan(line_data[:traffic].to_i)
    elsif line_data[:plan] == "standard"
      @fee = calc_standard_plan(line_data[:traffic].to_i)
    else
      # :planに想定外の値が入ってきた場合は固定で-1
      @fee = -1
      flash[:notice] = "プランを選択してください。"
    end
    
    if (line_data[:month].to_i > 12) || (line_data[:month].to_i < 1)
      @fee = -1
      flash[:notice] = "月は1～12を入力してください"
    end
    
    # エラーが発生していなければ保存
    if @fee != -1
      # 入力した月のデータがあるかどうかを確認
      @current_line = LineHistory.find_by(month: line_data[:month].to_i)
      if @current_line.present?
        @current_line.update_attributes!(fee: @fee, traffic: line_data[:traffic].to_i)
      else
        @current_line = LineHistory.new(fee: @fee, month: line_data[:month].to_i, traffic: line_data[:traffic].to_i)
        @current_line.save!
      end
    end
    
    # 1～12月分を昇順に取得
    @line_histories = LineHistory.where(month: 1..12).order(month: :asc)
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
    temp_trf = traffic - STANDARD_PLAN_FREE_TRF
    
    # 無料通信分以内であれば、追加なし
    return fee if temp_trf <= 0
    
    # 追加料金計算
    STANDARD_PLAN_FEE_PER_TRF.each do |one_fee|
      if temp_trf > one_fee[1]
        fee += one_fee[1] * one_fee[0]
        temp_trf -= one_fee[1]
      else
        fee += temp_trf * one_fee[0]
        break
      end
    end
    
    return fee
  end
  
  def line_history_params
    params.require(:line_history).permit(:month, :traffic, :plan)
  end
end
