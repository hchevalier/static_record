Rails.application.routes.draw do

  mount StaticRecord::Engine => "/static_record"
end
