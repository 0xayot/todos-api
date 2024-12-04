require 'rails_helper'
RSpec.describe '/users', type: :request do
  describe "POST /" do
    subject { -> { post '/users', params: request_body } }

    let(:request_body) do
      {
        email: Faker::Internet.free_email,
        password: SecureRandom.hex(8),
      }
    end

    context "when all requirements are fulfilled" do
      it "creates the user and returns a success status" do
        subject.call
    
        expect(response.status).to eq(201)
        body = JSON.parse(response.body)
        expect(body['user']['email']).to eq(request_body[:email])

      end
    end

    context "when the user already exists" do
      let!(:user) { create(:user) }
      let(:request_body) do
        {
          email: user.email,
          password: user.password
        }
      end

      it "returns a 401 with an error message" do
        subject.call
        body = JSON.parse(response.body)
        expect(response.status).to eq(401)
        expect(body['error_type']).to eq("existing_user")
        expect(body["error_message"]).to eq("A user with this email already exists")
      end
    end

    context "Validation checks" do 
      context "when no email is sent" do
        let(:request_body) do
          {
            password: "password",
          }
        end
        it "returns a 401" do 
          subject.call
          body = JSON.parse(response.body)
          expect(response.status).to eq(401)
          expect(body["errors"]["email"]).to eq("email required")
        end
      end
  
      context "when no password is sent" do
        let(:request_body) do
          {
            email: "email@email.com"
          }
        end
        it "returns a 401" do 
          subject.call
          body = JSON.parse(response.body)
          expect(response.status).to eq(401)
          expect(body["errors"]["password"]).to eq("password required")
        end
      end
    end
  end
end
