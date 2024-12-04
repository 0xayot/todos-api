class JwtAuthentication
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    if skip_authentication?(request)
      return @app.call(env)
    end

    auth_header = env['HTTP_AUTHORIZATION']
    
    if auth_header
      token = auth_header.split(' ').last
      
      begin
        decoded_token = decode_jwt_token(token)

        
        env['current_user'] = decoded_token

        pp decoded_token
        
        @app.call(env)
      rescue ActiveRecord::RecordNotFound => e
        unauthorized_response(e.message)
      rescue StandardError => e
        pp e 
        unauthorized_response("Authentication failed")
      end
    else
      unauthorized_response("No authentication token")
    end
  end

  private

  def skip_authentication?(request)
    unprotected_paths = [
      '/login', 
      '/users',
    ]
    
    unprotected_paths.any? { |path| request.path.start_with?(path) }
  end

  def decode_jwt_token(token)
    decoded_user = JWT.decode(
      token, 
      JWT_CONFIG[:secret_key], 
      true, 
      JWT_CONFIG[:decode_options]
    ).first
    User.find(decoded_user['sub'])
  end

  def unauthorized_response(message)
    body = { error: message }.to_json
    [401, {'Content-Type' => 'application/json'}, [body]]
  end
end