module JwtAuthHelper
  def generate_jwt_token(user)
    payload = {
      user_id: user.id,
      email: user.email,
      exp: (Time.current + 3.days).to_i
    }
    JWT.encode(payload, JWT_CONFIG[:secret_key], JWT_CONFIG[:algorithm])
  end

  def sign_in(user = create(:user))
    token = generate_jwt_token(user) 
    {
      headers: {
        'Authorization' => "Bearer #{token}",
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      }
    }
  end

  def sign_out
    {
      headers: {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      }
    }
  end
end


RSpec.configure do |config|
  config.include JwtAuthHelper, type: :controller
  config.include JwtAuthHelper, type: :request
  config.include JwtAuthHelper, type: :system

  config.before(:each, type: :system) do
  end
end