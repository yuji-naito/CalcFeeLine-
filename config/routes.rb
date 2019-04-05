Rails.application.routes.draw do
  #get 'calc_lines/home'

  root 'calc_lines#home'
  post 'calc_lines/calc'
end
