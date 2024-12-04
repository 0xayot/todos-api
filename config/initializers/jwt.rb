require 'jwt'

JWT_CONFIG = {
  token_lifetime: 3.days,
  
  algorithm: 'HS256',
  
  secret_key: ENV['JWT_SECRET'],

  payload_generator: ->(user) {
    {
      sub: user.id,
      exp: (Time.current + JWT_CONFIG[:token_lifetime]).to_i
    }
  },
  
  decode_options: {
    algorithm: 'HS256',
    verify_iat: true,
    verify_expiration: true
  }
}

def generate_jwt_token(user)
  payload = JWT_CONFIG[:payload_generator].call(user)
  JWT.encode(payload, JWT_CONFIG[:secret_key], JWT_CONFIG[:algorithm])
end


def decode_jwt_token(token)
  begin
    decoded_token = JWT.decode(
      token, 
      JWT_CONFIG[:secret_key], 
      true, 
      JWT_CONFIG[:decode_options]
    ).first

    User.find(decoded_token['sub'])
  rescue JWT::ExpiredSignature
    raise ActiveRecord::RecordNotFound, "Token has expired"
  rescue JWT::DecodeError
    raise ActiveRecord::RecordNotFound, "Invalid token"
  end
end