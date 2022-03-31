RSpec.describe 'PATCH /api/v1/bookings/id', type: :request do
  let(:host) { FactoryBot.create(:user) }
  let(:credentials_host) { host.create_new_auth_token }
  let(:headers_host) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials_host) }
  let!(:host_profile) do
    FactoryBot.create(
      :host_profile,
      user_id: host.id,
      availability: [1_562_803_200_000, 1_563_062_400_000, 1_563_148_800_000]
    )
  end

  let(:cat_owner) { FactoryBot.create(:user) }
  let(:credentials_cat_owner) { cat_owner.create_new_auth_token }
  let(:headers_cat_owner) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials_cat_owner) }

  let(:booking) do
    FactoryBot.create(
      :booking,
      host_nickname: host.nickname,
      user_id: cat_owner.id,
      dates: [1_562_803_200_000, 1_563_062_400_000]
    )
  end

  let!(:accepted_booking) do
    FactoryBot.create(
      :booking,
      host_nickname: host.nickname,
      host_profile_id: host_profile.id,
      user_id: cat_owner.id,
      status: 'accepted',
      dates: [1_662_976_000_000, 2_662_976_000_000]
    )
  end

  let(:cancelled_booking) do
    FactoryBot.create(:booking, host_nickname: host.nickname, user_id: cat_owner.id, dates: [1_662_976_000_000])
  end

  let(:unauthenticated_headers) { { HTTP_ACCEPT: 'application/json' } }

  def patch_request(book_id, book_status, book_message, book_headers)
    patch "/api/v1/bookings/#{book_id}",
          params: {
            status: book_status,
            host_message: book_message
          },
          headers: book_headers
  end

  describe 'succesfully' do
    describe 'when host accepts' do
      before do
        patch_request(booking.id, 'accepted', 'yeah baby!!!! cat wars!', headers_host)
        booking.reload
        host_profile.reload
      end

      it 'with 200 status' do
        expect(response.status).to eq 200
      end

      it 'with relevant message' do
        expect(json_response['message']).to eq 'You have successfully updated this booking!'
      end

      it 'with correct booking status' do
        expect(booking.status).to eq 'accepted'
      end

      it 'with correct booking host_message' do
        expect(booking.host_message).to eq 'yeah baby!!!! cat wars!'
      end

      it 'with correct booking host_description' do
        expect(booking.host_description).to eq host_profile.description
      end

      it 'with correct booking host_full_address' do
        expect(booking.host_full_address).to eq host_profile.full_address
      end

      it 'with correct booking host_real_lat' do
        expect(booking.host_real_lat).to eq host_profile.latitude
      end

      it 'with correct booking host_real_long' do
        expect(booking.host_real_long).to eq host_profile.longitude
      end

      it 'with updated host profile availability' do
        expect(host_profile.availability).to eq [1_563_148_800_000]
      end

      it 'with correct number of emails sent' do
        expect(Delayed::Job.all.count).to eq 1
      end

      it 'with email to user about accepted booking' do
        expect(Delayed::Job.first.handler.include?('notify_user_accepted_booking')).to eq true
      end
    end

    describe 'when host declines' do
      before do
        patch_request(booking.id, 'declined', 'sorry', headers_host)
        booking.reload
      end

      it 'with 200 status' do
        expect(response.status).to eq 200
      end

      it 'with relevant message' do
        expect(json_response['message']).to eq 'You have successfully updated this booking!'
      end

      it 'with correct booking status' do
        expect(booking.status).to eq 'declined'
      end

      it 'with correct booking host_message' do
        expect(booking.host_message).to eq 'sorry'
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
    end
  end

  describe 'unsuccessfully' do
    describe 'if another booking has already been accepted on the same date range' do
      before do
        patch_request(cancelled_booking.id, 'accepted', 'glad to be of assistance!', headers_host)
        cancelled_booking.reload
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
        expect(cancelled_booking.status).to eq 'canceled'
      end

      it 'with correct message on booking' do
        expect(
          cancelled_booking.host_message
        ).to eq 'This booking got canceled by KattBNB. The host has accepted another booking in that date range.'
      end
    end

    describe 'if host_message is over 200 characters' do
      before do
        patch_request(booking.id, 'accepted', 'accepted by host' * 15, headers_host)
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

    describe 'if action comes from the user that primarily requested the booking / an unassociated host' do
      before { patch_request(booking.id, 'accepted', 'accepted by host', headers_cat_owner) }

      it 'with 422 status' do
        expect(response.status).to eq 422
      end

      it 'with relevant error' do
        expect(json_response['error']).to eq 'You cannot perform this action!'
      end
    end

    describe 'if user is not authenticated' do
      before { patch_request(booking.id, '', '', unauthenticated_headers) }

      it 'with 401 status' do
        expect(response.status).to eq 401
      end

      it 'with relevant error' do
        expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
      end
    end

    describe 'if booking does not exist' do
      before { patch '/api/v1/bookings/2000000000', headers: headers_cat_owner }

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
