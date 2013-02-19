Rails.application.routes.draw do

  match 'cielo/callback' => 'checkout#cielo_callback'

end