RSpec::Benchmark.configure { |config| config.run_in_subprocess = true }

RSpec.describe Api::V1::BookingsController, type: :request do
  let(:host1) { FactoryBot.create(:user, email: 'george@mail.com', nickname: 'Alonso') }
  let(:host2) { FactoryBot.create(:user, email: 'noel@craft.com', nickname: 'MacOS') }
  let(:user1) { FactoryBot.create(:user, email: 'faraz@craft.com', nickname: 'EarlyInTheMorning') }
  let(:booking) do
    FactoryBot.create(
      :booking,
      host_nickname: host1.nickname,
      user_id: user1.id,
      dates: [1_562_889_600_000, 1_562_976_000_000]
    )
  end
  let!(:booking2) do
    FactoryBot.create(
      :booking,
      host_nickname: host1.nickname,
      user_id: user1.id,
      status: 'accepted',
      dates: [1_662_976_000_000, 2_662_976_000_000]
    )
  end
  let(:booking3) do
    FactoryBot.create(:booking, host_nickname: host1.nickname, user_id: user1.id, dates: [1_662_976_000_000])
  end
  let!(:profile1) do
    FactoryBot.create(
      :host_profile,
      user_id: host1.id,
      availability: [1_562_803_200_000, 1_563_062_400_000, 1_563_148_800_000],
      full_address: 'Arlanda Airport',
      description: 'It is a really fucking nice airport',
      latitude: 52.365598,
      longitude: 3.321478221
    )
  end
  let(:credentials_host1) { host1.create_new_auth_token }
  let(:credentials_host2) { host2.create_new_auth_token }
  let(:credentials_user1) { user1.create_new_auth_token }
  let(:headers_host1) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials_host1) }
  let(:headers_host2) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials_host2) }
  let(:headers_user1) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials_user1) }
  let(:headers_no_auth) { { HTTP_ACCEPT: 'application/json' } }

  describe 'PATCH /api/v1/bookings/id' do
    it 'updates status of certain booking if action comes from associated host' do
      patch "/api/v1/bookings/#{booking.id}",
            params: {
              status: 'accepted',
              host_message: 'accepted by host'
            },
            headers: headers_host1
      expect(response.status).to eq 555
      expect(
        json_response['error']
      ).to eq 'There was a problem connecting to our payments infrastructure provider. Please try again later.'
    end

    it 'updates status of certain booking to accepted in under 1 ms and with iteration rate of 5000000 per second' do
      patch_request =
        patch "/api/v1/bookings/#{booking.id}",
              params: {
                status: 'accepted',
                host_message: 'accepted by host'
              },
              headers: headers_host1
      expect { patch_request }.to perform_under(1).ms.sample(20).times
      expect { patch_request }.to perform_at_least(5_000_000).ips
    end

    it 'updates status of certain booking to declined in under 1 ms and with iteration rate of 5000000 per second' do
      patch_request =
        patch "/api/v1/bookings/#{booking.id}",
              params: {
                status: 'declined',
                host_message: 'iDecline!!!'
              },
              headers: headers_host1
      expect { patch_request }.to perform_under(1).ms.sample(20).times
      expect { patch_request }.to perform_at_least(5_000_000).ips
    end

    it 'cannot accept a booking if another one has already been accepted on the same date range' do
      patch "/api/v1/bookings/#{booking3.id}",
            params: {
              status: 'accepted',
              host_message: 'glad to be of assistance!'
            },
            headers: headers_host1

      expect(response.status).to eq 427
      expect(
        json_response['error']
      ).to eq 'You have already accepted a booking in that date range. This one will be canceled and we will notify the user.'
      expect(Delayed::Job.all.count).to eq 2
      expect(Delayed::Job.first.handler.include?('notify_user_declined_booking')).to eq true
      expect(Delayed::Job.last.handler.include?('notify_orphan_payment_intent_to_cancel')).to eq true
      booking3.reload
      expect(booking3.status).to eq 'canceled'
      expect(
        booking3.host_message
      ).to eq 'This booking got canceled by KattBNB. The host has accepted another booking in that date range.'
    end

    it 'does not update status of certain booking even if action comes from associated host cause host_message is more than 200 characters' do
      patch "/api/v1/bookings/#{booking.id}",
            params: {
              status: 'accepted',
              host_message:
                'accepted by host accepted by host accepted by host accepted by host accepted by host accepted by host accepted by host accepted by host accepted by host accepted by host accepted by host accepted by host'
            },
            headers: headers_host1
      expect(response.status).to eq 422
      expect(json_response['error']).to eq ['Host message is too long (maximum is 200 characters)']
      booking.reload
      expect(booking.status).to eq 'pending'
      expect(booking.host_message).to eq nil
    end

    it 'does not update status of certain booking if action comes from an unassociated host' do
      patch "/api/v1/bookings/#{booking.id}",
            params: {
              status: 'declined',
              host_message: 'declined by host'
            },
            headers: headers_host2
      expect(response.status).to eq 422
      expect(json_response['error']).to eq 'You cannot perform this action!'
    end

    it 'does not update status of certain booking even if action comes from the user that requested it in the first place' do
      patch "/api/v1/bookings/#{booking.id}",
            params: {
              status: 'accepted',
              host_message: 'accepted by host'
            },
            headers: headers_user1
      expect(response.status).to eq 422
      expect(json_response['error']).to eq 'You cannot perform this action!'
    end

    it 'does not update any booking if user is not authenticated' do
      patch "/api/v1/bookings/#{booking.id}", headers: headers_no_auth
      expect(response.status).to eq 401
      expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
    end

    it 'raises custom error in sad path where booking does not exist' do
      patch '/api/v1/bookings/2000000000', headers: headers_user1
      expect(response.status).to eq 404
      expect(json_response['error']).to eq [
           'We cannot update this booking because the user requested an account deletion! Please go back to your bookings page.'
         ]
    end
  end
end
