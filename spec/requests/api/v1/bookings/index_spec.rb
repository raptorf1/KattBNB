RSpec.describe "GET /api/v1/bookings", type: :request do
  let(:customer) { FactoryBot.create(:user, location: "Athens") }
  let(:customer_credentials) { customer.create_new_auth_token }
  let(:customer_headers) { { HTTP_ACCEPT: "application/json" }.merge!(customer_credentials) }

  let(:host_profile) { FactoryBot.create(:host_profile) }
  let(:host_credentials) { host_profile.user.create_new_auth_token }
  let(:host_headers) { { HTTP_ACCEPT: "application/json" }.merge!(host_credentials) }

  let(:random_user) { FactoryBot.create(:user, location: "Stockholm") }
  let(:random_user_credentials) { random_user.create_new_auth_token }
  let(:random_user_headers) { { HTTP_ACCEPT: "application/json" }.merge!(random_user_credentials) }

  let!(:booking) do
    FactoryBot.create(
      :booking,
      user_id: customer.id,
      host_nickname: host_profile.user.nickname,
      host_profile_id: host_profile.id,
      status: "accepted",
      dates: [1, 2, 3, 2_562_889_600_000]
    )
  end

  let!(:random_booking) do
    FactoryBot.create(
      :booking,
      host_nickname: host_profile.user.nickname,
      host_profile_id: host_profile.id,
      status: "accepted",
      dates: [4, 5, 6, 2_462_889_600_000]
    )
  end

  let(:unauthenticated_headers) { { HTTP_ACCEPT: "application/json" } }

  describe "successfully" do
    describe "when stats are asked for" do
      describe "and appropriate params are passed" do
        describe "with relevant stats for the host" do
          before do
            get "/api/v1/bookings",
                params: {
                  stats: "yes",
                  host_nickname: host_profile.user.nickname,
                  user_id: host_profile.user.id
                },
                headers: host_headers
          end

          it "is expected to return 200 response status" do
            expect(response.status).to eq 200
          end

          it "is expected to return correct booking stats" do
            expect(
              json_response["stats"].to_json
            ).to eq "{\"in_requests\":\"0\",\"in_upcoming\":\"2\",\"in_history\":\"0\",\"in_unpaid\":\"2\",\"out_requests\":\"0\",\"out_upcoming\":\"0\",\"out_history\":\"0\",\"out_unpaid\":\"0\"}"
          end
        end

        describe "with relevant stats for the customer" do
          before do
            get "/api/v1/bookings",
                params: {
                  stats: "yes",
                  host_nickname: customer.nickname,
                  user_id: customer.id
                },
                headers: customer_headers
          end

          it "is expected to return 200 response status" do
            expect(response.status).to eq 200
          end

          it "is expected to return correct booking stats" do
            expect(
              json_response["stats"].to_json
            ).to eq "{\"in_requests\":\"0\",\"in_upcoming\":\"0\",\"in_history\":\"0\",\"in_unpaid\":\"0\",\"out_requests\":\"0\",\"out_upcoming\":\"1\",\"out_history\":\"0\",\"out_unpaid\":\"1\"}"
          end
        end
      end

      describe "and no params are passed" do
        before { get "/api/v1/bookings", headers: customer_headers }

        it "is expected to return empty collection of bookings" do
          expect(json_response.count).to eq 0
        end

        it "is expected to return 200 response status" do
          expect(response.status).to eq 200
        end
      end
    end

    describe "when host asks for" do
      describe "bookings dates only" do
        before do
          get "/api/v1/bookings",
              params: {
                stats: "no",
                host_nickname: host_profile.user.nickname,
                dates: "only"
              },
              headers: host_headers
        end

        it "is expected to return 200 response status" do
          expect(response.status).to eq 200
        end

        it "is expected to return sorted array of booking dates" do
          expect(json_response).to eq [1, 2, 3, 4, 5, 6, 2_462_889_600_000, 2_562_889_600_000]
        end
      end

      describe "all of their bookings" do
        before do
          get "/api/v1/bookings",
              params: {
                stats: "no",
                host_nickname: host_profile.user.nickname
              },
              headers: host_headers
        end

        it "is expected to return 200 response status" do
          expect(response.status).to eq 200
        end

        it "is expected to return correct amount of bookings" do
          expect(json_response.count).to eq 2
        end
      end
    end

    describe "when customer asks for all their bookings" do
      before { get "/api/v1/bookings", params: { stats: "no", user_id: customer.id }, headers: customer_headers }

      it "with correct number of bookings" do
        expect(json_response.count).to eq 1
      end

      it "with correct booking" do
        expect(json_response.first["id"]).to eq booking.id
      end

      it "with correct number of keys in the response" do
        expect(json_response.first.count).to eq 22
      end

      it "with correct keys in the response" do
        expect(json_response.first).to include(
          "id",
          "number_of_cats",
          "dates",
          "status",
          "message",
          "host_nickname",
          "price_total",
          "user_id",
          "host_id",
          "host_profile_id",
          "user",
          "host_message",
          "host_description",
          "host_full_address",
          "host_location",
          "host_real_lat",
          "host_real_long",
          "host_avatar",
          "review_id",
          "host_profile_score"
        )
      end
    end
  end

  describe "unsuccessfully" do
    describe "if user is not logged in" do
      before { get "/api/v1/bookings/", headers: unauthenticated_headers }

      it "with 401 status" do
        expect(response.status).to eq 401
      end

      it "with relevant error" do
        expect(json_response["errors"]).to eq ["You need to sign in or sign up before continuing."]
      end
    end

    describe "if they try to see bookings they are unassociated with" do
      describe "for customers" do
        before { get "/api/v1/bookings", params: { stats: "no", user_id: customer.id }, headers: random_user_headers }

        it "with 200 status" do
          expect(response.status).to eq 200
        end

        it "with an empty array" do
          expect(json_response.count).to eq 0
        end
      end

      describe "for hosts" do
        before do
          get "/api/v1/bookings",
              params: {
                stats: "no",
                host_nickname: host_profile.user.nickname
              },
              headers: random_user_headers
        end

        it "with 200 status" do
          expect(response.status).to eq 200
        end

        it "with an empty array" do
          expect(json_response.count).to eq 0
        end
      end
    end
  end
end
