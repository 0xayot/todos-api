class UsersController < ApplicationController
  before_action :validate_params, only: :create
  before_action :validate_signup_request, only: :create
  before_action :validate_login_params!, only: :login
  before_action :authenticate, only: :login

  def show
    user = User.find(params[:id])
    render json: user
  end

  def create
    user = User.new(valid_params)

    if user.save!
      render json: {
        user: user
      }, status: 201 and return 
    end
  end

  def login
    render  json: {
      token: generate_jwt_token(entity),
    }, status: :created
  end


  # private
  def valid_params
    params.permit(ParamValidation::SIGNUP_PARAMS.map { |x| x.values.first })
  end

  def validate_signup_request
    error_type, error_message = if user_exists
      ["existing_user", user_exists_message ]
    end

    if error_type && error_message
      render json: {
        error_type: error_type,
        error_message: error_message
      }, status: 401 and return
    end
  end


  def validate_params
    errors = {}
    ParamValidation::SIGNUP_PARAMS.each do |parameter|
       if parameter[:required] && !params[parameter[:field]]
        errors[parameter[:field]] = "#{parameter[:field]} required"
       end
    end

    unless errors.empty?
      render json: {
        errors: errors
      }, status: 401 and return
    end
  end

  def user_exists
    User.exists?(email: params[:email].downcase.strip)
  end

  def user_exists_message 
    "A user with this email already exists"
  end


  # login methods

  def validate_login_params!
    missing_params = []
    
    ParamValidation::LOGIN_PARAMS.each do |parameter|
      if parameter[:required] && params[parameter[:field]].blank?
        missing_params << parameter[:field]
      end

      if parameter[:format] && !params[parameter[:field]].is_a?(parameter[:format])
        missing_params << parameter[:field]
      end
    end

    if missing_params.any?
      render json: { error: "Missing or invalid parameters: #{missing_params.join(', ')}" }, status: :unprocessable_entity
      return
    end
  end

  def auth_params
    params.permit(ParamValidation::LOGIN_PARAMS.map { |x| x.values.first })
  end

  def entity
    User.find_by(email: auth_params[:email].downcase.strip)
  end

  def authenticate
    if entity && !entity.authenticate(auth_params[:password])
      error_type, error_message = ["invalid_credentials", login_fail_message]

      render json: {
        error_type: error_type,
        error_message: error_message
      }, status: 401 and return
    end
  end

  def invalid_credentials
    render json: {
      error_type: "invalid_credentials",
      error_message: login_fail_message
    }, status: 401 and return
  end

  def login_fail_message
    "The credentials you have provided are not valid."
  end
end
