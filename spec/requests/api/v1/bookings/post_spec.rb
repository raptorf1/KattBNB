RSpec.describe 'POST /api/v1/booking', type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:credentials) { user.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials) }

  let(:user2) do
    FactoryBot.create(
      :user,
      email: 'chaos@thestreets.com',
      nickname: 'Joker',
      location: 'Athens',
      avatar: 'This is my avatar!!!'
    )
  end
  let!(:profile2) do
    FactoryBot.create(
      :host_profile,
      user_id: user2.id,
      availability: [1_562_803_200_000, 1_562_889_600_000, 1_562_976_000_000, 1_563_062_400_000, 1_563_148_800_000]
    )
  end

  let(:user3) { FactoryBot.create(:user, email: 'morechaos@thestreets.com', nickname: 'JJoker', location: 'Athens') }
  let!(:profile3) do
    FactoryBot.create(
      :host_profile,
      user_id: user3.id,
      availability: [1_562_803_200_000, 1_562_889_600_000, 1_562_976_000_000, 1_563_062_400_000, 1_563_148_800_000]
    )
  end

  let!(:booking) do
    FactoryBot.create(
      :booking,
      host_nickname: user3.nickname,
      user_id: user.id,
      status: 'accepted',
      dates: [1_563_188_800_000, 2_562_889_600_000]
    )
  end

  let(:not_headers) { { HTTP_ACCEPT: 'application/json' } }

  def post_request(req_message, req_host, req_dates)
    post '/api/v1/bookings',
         params: {
           number_of_cats: '2',
           message: req_message,
           host_nickname: req_host,
           dates: req_dates,
           price_per_day: '258.36',
           price_total: '1856',
           user_id: user.id,
           payment_intent_id: 'pi_32154dfdjfhjh'
         },
         headers: headers
  end

  describe 'successfully' do
    before { post_request('Take my cat, pls!', 'Joker', [1_562_976_000_000, 1_563_062_400_000]) }

    it 'with 200 status' do
      expect(response.status).to eq 200
    end

    it 'with relevant message' do
      expect(json_response['message']).to eq 'Successfully created!'
    end

    it 'sends an email' do
      expect(Delayed::Job.all.count).to eq 1
    end
  end

  describe 'unsuccessfully' do
    describe 'if not all fields are filled in' do
      before do
        post_request(
          '',
          'George',
          [1_562_803_200_000, 1_562_889_600_000, 1_562_976_000_000, 1_563_062_400_000, 1_563_148_800_000]
        )
      end

      it 'with 422 status' do
        expect(response.status).to eq 422
      end

      it 'with relevant error' do
        expect(json_response['error']).to eq ["Message can't be blank"]
      end

      it 'with correct number of sent emails' do
        expect(Delayed::Job.all.count).to eq 1
      end

      it 'with relevant email for Stripe action' do
        expect(Delayed::Job.first.handler).to include('notify_orphan_payment_intent_to_cancel')
      end
    end

    describe 'if message length is over 400 characters' do
      before do
        post_request(
          "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
          'George',
          [1_562_803_200_000, 1_562_889_600_000, 1_562_976_000_000, 1_563_062_400_000, 1_563_148_800_000]
        )
      end

      it 'with 422 status' do
        expect(response.status).to eq 422
      end

      it 'with relevant error' do
        expect(json_response['error']).to eq ['Message is too long (maximum is 400 characters)']
      end
    end

    describe "if host already accepted someone else's booking request with similar dates" do
      before { post_request('Lorem Ipsum is simply dummy text.', 'JJoker', [1_563_168_800_000, 1_563_188_800_000]) }

      it 'with 422 status' do
        expect(response.status).to eq 422
      end

      it 'with relevant error' do
        expect(json_response['error']).to eq ['Someone else just requested to book these days with this host!']
      end
    end

    describe 'if host deletes their account in the proccess' do
      before { post_request('Lorem Ipsum is simply dummy text.', 'Batman', [1_562_803_200_000, 1_562_889_600_000]) }

      it 'with 422 status' do
        expect(response.status).to eq 422
      end

      it 'with relevant error' do
        expect(json_response['error']).to eq [
             'Booking cannot be created because the host requested an account deletion! Please find another host in the results page.'
           ]
      end
    end

    describe 'if user is not logged in' do
      before { post '/api/v1/bookings', headers: not_headers }

      it 'with 401 status' do
        expect(response.status).to eq 401
      end

      it 'with relevant error' do
        expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
      end
    end
  end
end
