RSpec.describe 'PATCH /api/v1/bookings/id', type: :request do
  let(:host1) { FactoryBot.create(:user, email: 'george@mail.com', nickname: 'Alonso') }
  let(:credentials_host1) { host1.create_new_auth_token }
  let(:headers_host1) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials_host1) }
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

  let(:host2) { FactoryBot.create(:user, email: 'noel@craft.com', nickname: 'MacOS') }
  let(:credentials_host2) { host2.create_new_auth_token }
  let(:headers_host2) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials_host2) }

  let(:user1) { FactoryBot.create(:user, email: 'faraz@craft.com', nickname: 'EarlyInTheMorning') }
  let(:credentials_user1) { user1.create_new_auth_token }
  let(:headers_user1) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials_user1) }

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

  let(:headers_no_auth) { { HTTP_ACCEPT: 'application/json' } }

  def patch_request(book_id, book_status, book_message, book_headers)
    patch "/api/v1/bookings/#{book_id}",
          params: {
            status: book_status,
            host_message: book_message
          },
          headers: book_headers
  end

  describe 'unsuccessfully' do
    describe 'cause of Stripe error when capturing the money' do
      before do
        patch_request(booking.id, 'accepted', 'accepted by host', headers_host1)
        booking.reload
      end

      it 'with 555 status' do
        expect(response.status).to eq 555
      end

      it 'with relevant error' do
        expect(
          json_response['error']
        ).to eq 'There was a problem connecting to our payments infrastructure provider. Please try again later.'
      end

      it 'with correct booking status' do
        expect(booking.status).to eq 'pending'
      end

      it 'with correct booking host_message' do
        expect(booking.host_message).to eq nil
      end
    end

    describe 'if another booking has already been accepted on the same date range' do
      before do
        patch_request(booking3.id, 'accepted', 'glad to be of assistance!', headers_host1)
        booking3.reload
      end

      it 'with 427 status' do
        expect(response.status).to eq 427
      end

      it 'with relevant error' do
        expect(
          json_response['error']
        ).to eq 'You have already accepted a booking in that date range. This one will be canceled and we will notify the user.'
      end

      it 'with correct number of emails sent' do
        expect(Delayed::Job.all.count).to eq 2
      end

      it 'with email to user about declined booking' do
        expect(Delayed::Job.first.handler.include?('notify_user_declined_booking')).to eq true
      end

      it 'with email to KattBNB about Stripe payment intent' do
        expect(Delayed::Job.last.handler.include?('notify_orphan_payment_intent_to_cancel')).to eq true
      end

      it 'with correct status on booking' do
        expect(booking3.status).to eq 'canceled'
      end

      it 'with correct message on booking' do
        expect(
          booking3.host_message
        ).to eq 'This booking got canceled by KattBNB. The host has accepted another booking in that date range.'
      end
    end

    describe 'if host_message is over 200 characters' do
      before do
        patch_request(
          booking.id,
          'accepted',
          'accepted by host accepted by host accepted by host accepted by host accepted by host accepted by host accepted by host accepted by host accepted by host accepted by host accepted by host accepted by host',
          headers_host1
        )
        booking.reload
      end

      it 'with 422 status' do
        expect(response.status).to eq 422
      end

      it 'with relevant error' do
        expect(json_response['error']).to eq ['Host message is too long (maximum is 200 characters)']
      end

      it 'with correct booking status' do
        expect(booking.status).to eq 'pending'
      end

      it 'with no host_message' do
        expect(booking.host_message).to eq nil
      end
    end

    describe 'if action comes from an unassociated host' do
      before { patch_request(booking.id, 'declined', 'declined by host', headers_host2) }

      it 'with 422 status' do
        expect(response.status).to eq 422
      end

      it 'with relevant error' do
        expect(json_response['error']).to eq 'You cannot perform this action!'
      end
    end

    describe 'even if action comes from the user that primarily requested the booking' do
      before { patch_request(booking.id, 'accepted', 'accepted by host', headers_user1) }

      it 'with 422 status' do
        expect(response.status).to eq 422
      end

      it 'with relevant error' do
        expect(json_response['error']).to eq 'You cannot perform this action!'
      end
    end

    describe 'if user is not authenticated' do
      before { patch_request(booking.id, '', '', headers_no_auth) }

      it 'with 401 status' do
        expect(response.status).to eq 401
      end

      it 'with relevant error' do
        expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
      end
    end

    describe 'if booking does not exist' do
      before { patch '/api/v1/bookings/2000000000', headers: headers_user1 }

      it 'with custom 404 status' do
        expect(response.status).to eq 404
      end

      it 'with relevant error' do
        expect(json_response['error']).to eq [
             'We cannot update this booking because the user requested an account deletion! Please go back to your bookings page.'
           ]
      end
    end
  end
end
