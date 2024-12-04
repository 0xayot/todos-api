module JwtAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request!
  end

  private

  def authenticate_request!
    @current_user = request.env['current_user']
    render json: { error: 'Not Authenticated' }, status: :unauthorized unless @current_user
  end

  def current_user
    @current_user
  end
end