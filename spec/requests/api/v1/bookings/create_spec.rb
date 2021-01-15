RSpec::Benchmark.configure do |config|
  config.run_in_subprocess = true
end

RSpec.describe Api::V1::BookingsController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let!(:user2) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker', location: 'Athens', avatar: 'This is my avatar!!!') }
  let!(:profile2) { FactoryBot.create(:host_profile, user_id: user2.id, availability: [1562803200000, 1562889600000, 1562976000000, 1563062400000, 1563148800000])}
  let!(:user3) { FactoryBot.create(:user, email: 'morechaos@thestreets.com', nickname: 'JJoker', location: 'Athens') }
  let!(:profile3) { FactoryBot.create(:host_profile, user_id: user3.id, availability: [1562803200000, 1562889600000, 1562976000000, 1563062400000, 1563148800000])}
  let!(:booking) { FactoryBot.create(:booking, host_nickname: user3.nickname, user_id: user.id, status: 'accepted', dates: [1563188800000, 2562889600000]) }
  let!(:user4) { FactoryBot.create(:user, email: 'more@thestreets.com', nickname: 'Alonso', location: 'Athens') }
  let!(:profile4) { FactoryBot.create(:host_profile, user_id: user4.id, availability: [])}
  let!(:booking2) { FactoryBot.create(:booking, host_nickname: user4.nickname, user_id: user.id, status: 'pending', dates: [1562889600000]) }
  let(:credentials) { user.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: "application/json" }.merge!(credentials) }
  let(:not_headers) { {HTTP_ACCEPT: "application/json"} }

  describe 'POST /api/v1/booking' do

    describe 'successfully' do
      before do
        post '/api/v1/bookings', params: {
          number_of_cats: '2',
          message: 'Take my cat, pls!',
          host_nickname: 'Joker',
          dates: [1562976000000, 1563062400000],
          price_per_day: '258.36',
          price_total: '1856',
          user_id: user.id,
          payment_intent_id: 'pi_32154dfdjfhjh'
        },
        headers: headers
      end

      it 'creates a booking' do
        expect(json_response['message']).to eq 'Successfully created!'
        expect(response.status).to eq 200
      end

      it 'sends an email upon booking creation' do
        expect(Delayed::Job.all.count).to eq 1
      end

      it 'alters hosts availability' do
        profile2.reload
        expect(profile2.availability).to eq [1562803200000, 1562889600000, 1563148800000]
      end

      it 'creates another booking and sends a second email' do
        post '/api/v1/bookings', params: {
          number_of_cats: '23',
          message: 'I want my cats to have a good time, pls!',
          host_nickname: 'JJoker',
          dates: [1562803200000, 1562889600000],
          price_per_day: '125.96',
          price_total: '1452.36',
          user_id: user.id,
          payment_intent_id: 'pi_32154dfdjfhjh'
        },
        headers: headers

        expect(json_response['message']).to eq 'Successfully created!'
        expect(response.status).to eq 200
        expect(user.booking.length).to eq 4
        expect(Delayed::Job.all.count).to eq 2
      end

      it 'creates booking in under 1 ms and with iteration rate of 5000000 per second' do
        post_request = post '/api/v1/bookings', params: {
          number_of_cats: '23',
          message: 'I want my cats to have a good time, pls!',
          host_nickname: 'JJoker',
          dates: [1562803200000, 1562889600000],
          price_per_day: '125.96',
          price_total: '1452.36',
          user_id: user.id
        },
        headers: headers
        expect { post_request }.to perform_under(1).ms.sample(20).times
        expect { post_request }.to perform_at_least(5000000).ips
      end
    end

    describe 'unsuccessfully' do
      it 'Booking cannot be created without all fields filled in' do
        post '/api/v1/bookings', params: {
          number_of_cats: '2',
          host_nickname: 'George',
          dates: [1562803200000, 1562889600000, 1562976000000, 1563062400000, 1563148800000],
          price_per_day: '105.96',
          price_total: '1400.36',
          user_id: user.id,
          payment_intent_id: 'pi_32154dfdjfhjh'
        },
        headers: headers

        expect(json_response['error']).to eq ["Message can't be blank"]
        expect(response.status).to eq 422
        expect(user.booking.length).to eq 2
        first_booking = user.booking.select { |user_booking| user_booking.id == booking.id }
        second_booking = user.booking.select { |user_booking| user_booking.id == booking2.id }
        expect(first_booking.length).to eq 1
        expect(second_booking.length).to eq 1
        expect(Delayed::Job.all.count).to eq 1
      end

      it 'Booking cannot be created if message is more than 400 characters in length' do
        post '/api/v1/bookings', params: {
          number_of_cats: '2',
          host_nickname: 'George',
          dates: [1562803200000, 1562889600000, 1562976000000, 1563062400000, 1563148800000],
          price_per_day: '105.96',
          price_total: '1400.36',
          user_id: user.id,
          payment_intent_id: 'pi_32154dfdjfhjh',
          message: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."
        },
        headers: headers

        expect(json_response['error']).to eq ['Message is too long (maximum is 400 characters)']
        expect(response.status).to eq 422
        expect(user.booking.length).to eq 2
        first_booking = user.booking.select { |user_booking| user_booking.id == booking.id }
        second_booking = user.booking.select { |user_booking| user_booking.id == booking2.id }
        expect(first_booking.length).to eq 1
        expect(second_booking.length).to eq 1
        expect(Delayed::Job.all.count).to eq 1
      end

      it "Booking cannot be created if someone else booked the host in the process - pending booking" do
        post '/api/v1/bookings', params: {
          number_of_cats: '2',
          host_nickname: 'Alonso',
          dates: [1562803200000, 1562889600000],
          price_per_day: '105.96',
          price_total: '1400.36',
          user_id: user.id,
          payment_intent_id: 'pi_32154dfdjfhjh',
          message: 'Lorem Ipsum is simply dummy text.'
        },
        headers: headers

        expect(json_response['error']).to eq ['Someone else just requested to book these days with this host!']
        expect(response.status).to eq 422
        expect(user.booking.length).to eq 2
        first_booking = user.booking.select { |user_booking| user_booking.id == booking.id }
        second_booking = user.booking.select { |user_booking| user_booking.id == booking2.id }
        expect(first_booking.length).to eq 1
        expect(second_booking.length).to eq 1
        expect(Delayed::Job.all.count).to eq 1
      end

      it "Booking cannot be created if someone else booked the host in the process - upcoming booking" do
        post '/api/v1/bookings', params: {
          number_of_cats: '2',
          host_nickname: 'JJoker',
          dates: [1563168800000, 1563188800000],
          price_per_day: '105.96',
          price_total: '1400.36',
          user_id: user.id,
          payment_intent_id: 'pi_32154dfdjfhjh',
          message: 'Lorem Ipsum is simply dummy text.'
        },
        headers: headers

        expect(json_response['error']).to eq ['Someone else just requested to book these days with this host!']
        expect(response.status).to eq 422
        expect(user.booking.length).to eq 2
        first_booking = user.booking.select { |user_booking| user_booking.id == booking.id }
        second_booking = user.booking.select { |user_booking| user_booking.id == booking2.id }
        expect(first_booking.length).to eq 1
        expect(second_booking.length).to eq 1
        expect(Delayed::Job.all.count).to eq 1
      end

      it 'Booking cannot be created if host deletes her account in the proccess' do
        post '/api/v1/bookings', params: {
          number_of_cats: '2',
          host_nickname: 'Batman',
          dates: [1562803200000, 1562889600000],
          price_per_day: '105.96',
          price_total: '1400.36',
          user_id: user.id,
          payment_intent_id: 'pi_32154dfdjfhjh',
          message: 'Lorem Ipsum is simply dummy text.'
        },
        headers: headers

        expect(json_response['error']).to eq ['Booking cannot be created because the host requested an account deletion! Please find another host in the results page.']
        expect(response.status).to eq 422
        expect(user.booking.length).to eq 2
        first_booking = user.booking.select { |user_booking| user_booking.id == booking.id }
        second_booking = user.booking.select { |user_booking| user_booking.id == booking2.id }
        expect(first_booking.length).to eq 1
        expect(second_booking.length).to eq 1
        expect(Delayed::Job.all.count).to eq 1
      end

      it 'Booking cannot be created if user is not logged in' do
        post '/api/v1/bookings', headers: not_headers
        expect(json_response['errors']).to eq ['You need to sign in or sign up before continuing.']
      end
    end
  end
end
