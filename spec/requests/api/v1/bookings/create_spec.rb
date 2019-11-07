RSpec.describe Api::V1::BookingsController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:credentials) { user.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: "application/json" }.merge!(credentials) }
  let(:not_headers) { {HTTP_ACCEPT: "application/json"} }

  describe 'POST /api/v1/booking' do

    describe 'successfully' do
      before do
        post '/api/v1/bookings', params: {
          number_of_cats: '2',
          message: 'Take my cat, pls!',
          host_nickname: 'George',
          dates: [1562803200000, 1562889600000, 1562976000000, 1563062400000, 1563148800000],
          user_id: user.id
        }, 
        headers: headers
      end

      it 'creates a booking' do
        expect(json_response['message']).to eq 'Successfully created'
        expect(response.status).to eq 200
      end

      it 'creates another booking' do
        post '/api/v1/bookings', params: {
          number_of_cats: '23',
          message: 'I want my cats to have a good time, pls!',
          host_nickname: 'Zane',
          dates: [1562803200000, 1562889600000],
          user_id: user.id
        }, 
        headers: headers

        expect(json_response['message']).to eq 'Successfully created'
        expect(response.status).to eq 200
        expect(user.booking.length).to eq 2
      end
    end

    describe 'unsuccessfully' do
      it 'Booking can not be created without all fields filled in' do
        post '/api/v1/bookings', params: {
          number_of_cats: '2',
          host_nickname: 'George',
          dates: [1562803200000, 1562889600000, 1562976000000, 1563062400000, 1563148800000],
          user_id: user.id
        }, 
        headers: headers

        expect(json_response['error']).to eq ["Message can't be blank"]
        expect(response.status).to eq 422
      end

      it 'Booking can not be created if user is not logged in' do
        post '/api/v1/bookings', headers: not_headers
        expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
      end
    end
  end
end
