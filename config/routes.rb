Rs::Application.routes.draw do
  
  get 'carpool/login/:id'         => 'carpools#login', via: [:get, :post]
  get 'carpool/email'             => 'carpools#email'
  post 'carpool/email'            => 'carpools#email_submit'
  get 'carpool/get_coordinates'   => 'carpools#get_coordinates'
  get 'carpool/report'            => 'carpools#report'
  
  get  'carpool/register/:id'     => 'carpools#register'
  match 'carpool/register'        => 'carpools#register', as: 'register_submit', via: [:get, :post]
  get 'crs/ride'                => 'carpools#register'
  patch  'carpool/register/:id'    => 'carpools#register_update', as: 'register_update'
  
  put 'carpool/add_rider'         => 'carpools#add_rider'
  put 'carpool/remove_rider'      => 'carpools#remove_rider'
  
  match 'carpool/update_addresses'  => 'carpools#update_addresses', via: [:get, :update]
  get 'carpool/:id/empty'         => 'carpools#empty'
  get 'carpool/:id'               => 'carpools#index'
  get 'carpool'                   => 'carpools#index'
  
  root :to => 'carpools#index'

end

