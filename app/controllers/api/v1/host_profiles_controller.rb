class Api::V1::HostProfilesController < ApplicationController
  
  before_action :authenticate_api_v1_user!, only: [:create]


  def create
    
  end

  
  private

  def host_profile_params
    params.permit( )
  end

end
