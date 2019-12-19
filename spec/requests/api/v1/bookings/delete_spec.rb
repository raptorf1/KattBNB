RSpec.describe Api::V1::HostProfilesController, type: :request do
  let(:user) { FactoryBot.create(:user, email: 'george@mail.com', nickname: 'Alonso') }
  let(:user2) { FactoryBot.create(:user, email: 'zane@mail.com', nickname: 'Kitten') }
  let!(:host_profile_user2) { FactoryBot.create(:host_profile, user_id: user2.id, availability: [1, 2, 3, 4, 5]) }
  let(:booking) { FactoryBot.create(:booking, host_nickname: user2.nickname, user_id: user.id, status: 'declined') }
  let(:booking2) { FactoryBot.create(:booking, host_nickname: user2.nickname, user_id: user.id, status: 'canceled') }
  let(:booking3) { FactoryBot.create(:booking, host_nickname: user2.nickname, user_id: user.id, status: 'pending', dates: [1562889600000, 1562976000000]) }
  let(:booking4) { FactoryBot.create(:booking, host_nickname: user2.nickname, user_id: user.id, status: 'accepted', dates: [2562889600000, 2562976000000]) }
  let(:booking5) { FactoryBot.create(:booking, host_nickname: user2.nickname, user_id: user.id, status: 'accepted', dates: [1462889600000, 1462976000000]) }
  let(:user_credentials) { user.create_new_auth_token }
  let(:user2_credentials) { user2.create_new_auth_token }
  let(:user_headers) { { HTTP_ACCEPT: 'application/json' }.merge!(user_credentials) }
  let(:user2_headers) { { HTTP_ACCEPT: 'application/json' }.merge!(user2_credentials) }
  let(:headers_no_auth) { { HTTP_ACCEPT: 'application/json' } }

  describe 'DELETE /api/v1/bookings/id' do

    it 'deletes the declined booking of the associated user and does not delete the user' do
      delete "/api/v1/bookings/#{booking.id}", headers: user_headers
      expect(response.status).to eq 200
      expect(json_response['message']).to eq 'You have successfully deleted this declined or canceled booking'
      expect(User.all.length).to eq 2
      expect(User.last.present?).to eq true
      expect(User.last.uid).to eq 'george@mail.com'
      expect(Booking.all.length).to eq 0
    end

    it 'deletes the cancelled booking of the associated user' do
      delete "/api/v1/bookings/#{booking2.id}", headers: user_headers
      expect(response.status).to eq 200
      expect(json_response['message']).to eq 'You have successfully deleted this declined or canceled booking'
      expect(Booking.all.length).to eq 0
    end

    it 'deletes the pending booking of the associated user and adds back availability to associated host profile' do
      delete "/api/v1/bookings/#{booking3.id}", headers: user_headers
      expect(response.status).to eq 200
      expect(json_response['message']).to eq 'You have successfully deleted this pending booking'
      expect(Booking.all.length).to eq 0
      host_profile_user2.reload
      expect(host_profile_user2.availability).to eq [1, 2, 3, 4, 5, 1562889600000, 1562976000000]
    end

    it 'deletes the accepted past booking of the associated user' do
      delete "/api/v1/bookings/#{booking5.id}", headers: user_headers
      expect(response.status).to eq 200
      expect(json_response['message']).to eq 'You have successfully deleted an accepted booking of the past'
      expect(Booking.all.length).to eq 0
    end

    it 'deletes the accepted upcoming booking of the associated user and sends an email to the associated host' do
      delete "/api/v1/bookings/#{booking4.id}", headers: user_headers
      expect(Booking.all.length).to eq 0
      expect(ActionMailer::Base.deliveries.count).to eq 1
    end

    it 'does not delete booking associated with another user' do
      delete "/api/v1/bookings/#{booking.id}", headers: user2_headers
      expect(response.status).to eq 422
      expect(json_response['error']).to eq 'You cannot perform this action'
    end

    it 'does not delete any booking if user is not authenticated' do
      delete "/api/v1/bookings/#{booking.id}", headers: headers_no_auth
      expect(response.status).to eq 401
      expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
    end
  end
end
