class UsersController < ApplicationController
  before_action :validate_params, only: :create
  before_action :validate_signup_request, only: :create
  before_action :validate_login_params!, only: :login
  before_action :authenticate, only: :login

  def current_user
    begin
      decoded_user = JWT.decode(
        request.headers['Authorization'].split(' ').last, 
        JWT_CONFIG[:secret_key], 
        true, 
        JWT_CONFIG[:decode_options]
      ).first
      user = User.find(decoded_user['sub'])
      render json: {user: user} , status: 200 and return 
    rescue 
      render json: {
        error_type: "invalid_user",
        error_message: "User not found"
      }, status: 400 and return
    end
    
  end

  def create
    user = User.new(valid_params)


    begin
      user.save!
      render json: {
        user: user
      }, status: 201 and return 
    rescue StandardError => e
      Rails.logger.error "Error creating user: #{e.message}"
      render json: { error: "An error occured." }, status: :unprocessable_entity
    end
  end

  def login
    render  json: {
      token: generate_jwt_token(entity),
    }, status: :created
  end


  private
  def valid_params
    params.permit(ParamValidation::SIGNUP_PARAMS.map { |x| x.values.first })
  end

  def valid_email_format?
    regex = /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\z/
    regex.match(params[:email].strip)
  end

  def valid_password_length?
    params[:password].length >= 8
  end

  def valid_password?
    password = params[:password]
    password.match(/[A-Z]/) && password.match(/[a-z]/) && password.match(/\d/) && password.match(/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/)
  end
  

  def validate_signup_request
    error_type, error_message = if user_exists
      ["existing_user", user_exists_message ]
    elsif !valid_email_format?
      ["invalid_email", "Email format is invalid"  ]
    elsif !valid_password_length?
      ["invalid_password", "Password must be at least 8 characters long"]
    elsif !valid_password?
      ["invalid_password", "Password must have one uppercase letter, one lowercase letter, one digit, and one special character"]
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
