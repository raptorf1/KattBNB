RSpec.describe Api::V1::BookingsController, type: :request do
  let(:host1) { FactoryBot.create(:user, email: 'george@mail.com', nickname: 'Alonso') }
  let(:host2) { FactoryBot.create(:user, email: 'noel@craft.com', nickname: 'MacOS') }
  let(:user1) { FactoryBot.create(:user, email: 'faraz@craft.com', nickname: 'EarlyInTheMorning') }
  let(:booking) { FactoryBot.create(:booking, host_nickname: host1.nickname, user_id: user1.id) }
  let(:credentials_host1) { host1.create_new_auth_token }
  let(:credentials_host2) { host2.create_new_auth_token }
  let(:credentials_user1) { user1.create_new_auth_token }
  let(:headers_host1) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials_host1) }
  let(:headers_host2) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials_host2) }
  let(:headers_user1) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials_user1) }
  let(:headers_no_auth) { { HTTP_ACCEPT: 'application/json' } }

  describe 'PATCH /api/v1/bookings/id' do

    it 'updates status of certain booking if action comes from associated host' do
      patch "/api/v1/bookings/#{booking.id}", params: {
        status: 'accepted',
        host_message: 'accepted by host'
      },
      headers: headers_host1
      expect(response.status).to eq 200
      expect(json_response['message']).to eq 'You have successfully updated this booking'
      booking.reload
      expect(booking.status).to eq 'accepted'
      expect(booking.host_message).to eq 'accepted by host'
    end

    it 'does not update status of certain booking even if action comes from associated host cause host_message is more than 200 characters' do
      patch "/api/v1/bookings/#{booking.id}", params: {
        status: 'accepted',
        host_message: 'accepted by host accepted by host accepted by host accepted by host accepted by host accepted by host accepted by host accepted by host accepted by host accepted by host accepted by host accepted by host'
      },
      headers: headers_host1
      expect(response.status).to eq 422
      expect(json_response['error']).to eq ['Host message is too long (maximum is 200 characters)']
      booking.reload
      expect(booking.status).to eq 'pending'
      expect(booking.host_message).to eq nil
    end

    it 'does not update status of certain booking if action comes from an unassociated host' do
      patch "/api/v1/bookings/#{booking.id}", params: {
        status: 'declined',
        host_message: 'declined by host'
      },
      headers: headers_host2
      expect(response.status).to eq 422
      expect(json_response['error']).to eq 'You cannot perform this action'
    end

    it 'does not update status of certain booking even if action comes from the user that requested it in the first place' do
      patch "/api/v1/bookings/#{booking.id}", params: {
        status: 'accepted',
        host_message: 'accepted by host'
      },
      headers: headers_user1
      expect(response.status).to eq 422
      expect(json_response['error']).to eq 'You cannot perform this action'
    end

    it 'does not update any booking if user is not authenticated' do
      patch "/api/v1/bookings/#{booking.id}", headers: headers_no_auth
      expect(response.status).to eq 401
      expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
    end
  end
end
