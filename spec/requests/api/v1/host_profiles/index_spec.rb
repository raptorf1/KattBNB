RSpec.describe "GET /api/v1/host_profiles", type: :request do
  let(:user) { FactoryBot.create(:user, location: "Athens") }
  let(:profile_user) do
    FactoryBot.create(
      :host_profile,
      user_id: user.id,
      max_cats_accepted: 5,
      availability: [1_587_945_600_000, 1_588_032_000_000, 1_588_118_400_000, 1_588_204_800_000]
    )
  end
  let(:booking) { FactoryBot.create(:booking, user_id: user.id) }
  let!(:booking_2) do
    FactoryBot.create(
      :booking,
      user_id: user.id,
      host_nickname: a_fourth_user.nickname,
      host_profile_id: profile_fourth_user.id,
      status: "accepted",
      dates: [1_588_204_800_000, 2_588_204_800_000]
    )
  end
  let!(:review) do
    FactoryBot.create(:review, user_id: user.id, booking_id: booking.id, host_profile_id: profile_user.id)
  end

  let(:another_user) { FactoryBot.create(:user, location: "Crete") }
  let!(:profile_another_user) do
    FactoryBot.create(
      :host_profile,
      user_id: another_user.id,
      max_cats_accepted: 7,
      availability: [1_588_032_000_000, 1_588_118_400_000, 1_588_204_800_000]
    )
  end

  let(:a_third_user) { FactoryBot.create(:user, location: "Rhodos") }
  let!(:profile_third_user) do
    FactoryBot.create(:host_profile, user_id: a_third_user.id, max_cats_accepted: 3, availability: [])
  end

  let(:a_fourth_user) { FactoryBot.create(:user, location: "Sifnos") }
  let!(:profile_fourth_user) do
    FactoryBot.create(:host_profile, user_id: a_fourth_user.id, max_cats_accepted: 4, availability: [1_588_118_400_000])
  end

  describe "succesfully" do
    describe "according to availability" do
      before { get "/api/v1/host_profiles?cats=2&startDate=1588032000000&endDate=1588204800000" }

      it "with 200 status" do
        expect(response.status).to eq 200
      end

      it "with correct number of host profiles with availability" do
        expect(json_response["with"].count).to eq 2
      end

      it "with correct number of host profiles without availability" do
        expect(json_response["without"].count).to eq 1
      end

      it "with correct host profile without availability" do
        expect(json_response["without"].first["id"]).to eq profile_third_user.id
      end

      it "excluding non matching host profile without availability" do
        expect(json_response["without"].first["id"]).not_to eq profile_fourth_user.id
      end
    end

    describe "according to date params" do
      before { get "/api/v1/host_profiles?cats=2&startDate=1587945600000&endDate=1588118400000" }

      it "with correct number of host profiles with availability" do
        expect(json_response["with"].count).to eq 1
      end

      it "with correct number of host profiles without availability" do
        expect(json_response["without"].count).to eq 3
      end

      it "with correct available host profile" do
        expect(json_response["with"].first["id"]).to eq profile_user.id
      end
    end

    describe "according to cat params" do
      before { get "/api/v1/host_profiles?cats=6&startDate=1588032000000&endDate=1588118400000" }

      it "with correct number of host profiles with availability" do
        expect(json_response["with"].count).to eq 1
      end

      it "with correct number of host profiles without availability" do
        expect(json_response["without"].count).to eq 0
      end

      it "with correct available host profile" do
        expect(json_response["with"].first["id"]).to eq profile_another_user.id
      end
    end

    describe "according to date and cat params" do
      before { get "/api/v1/host_profiles?cats=8&startDate=1588118400000&endDate=1588291200000" }

      it "with correct number of host profiles with availability" do
        expect(json_response["with"].count).to eq 0
      end

      it "with correct number of host profiles without availability" do
        expect(json_response["without"].count).to eq 0
      end
    end

    describe "according to reviews" do
      before do
        get "/api/v1/host_profiles?cats=2&startDate=1588032000000&endDate=1588204800000"
        @with_review = json_response["with"].select { |profile| profile["reviews_count"] == 1 }
        @no_review = json_response["with"].select { |profile| profile["reviews_count"] == nil }
      end

      it "with correct number of host profiles with reviews" do
        expect(@with_review.length).to eq 1
      end

      it "with correct number of host profiles without reviews" do
        expect(@no_review.length).to eq 1
      end

      it "with correct host profiles with reviews" do
        expect(@with_review.first["id"]).to eq profile_user.id
      end

      it "with correct host profiles without reviews" do
        expect(@no_review[0]["id"]).to eq profile_another_user.id
      end
    end

    describe "for a specific user" do
      before { get "/api/v1/host_profiles", params: { user_id: another_user.id } }

      it "with correct number of host profiles" do
        expect(json_response.count).to eq 1
      end

      it "with specific user's host profile" do
        expect(json_response.first["user"]["id"]).to eq another_user.id
      end
    end

    describe "for a specific location" do
      describe "according to that location only" do
        before do
          get "/api/v1/host_profiles",
              params: {
                location: another_user.location,
                cats: 2,
                startDate: 1_588_032_000_000,
                endDate: 1_588_204_800_000
              }
        end

        it "with correct number of host profiles with availability" do
          expect(json_response["with"].count).to eq 1
        end

        it "with correct number of host profiles without availability" do
          expect(json_response["without"].count).to eq 0
        end

        it "with correct location of host profiles with availability" do
          expect(json_response["with"].first["user"]["location"]).to eq another_user.location
        end

        it "with correct host profiles with availability" do
          expect(json_response["with"].first["id"]).to eq profile_another_user.id
        end
      end

      describe "according to that location and date params" do
        before do
          get "/api/v1/host_profiles",
              params: {
                location: another_user.location,
                cats: 2,
                startDate: 1_588_032_000_000,
                endDate: 1_588_291_200_000
              }
        end

        it "with correct number of host profiles with availability" do
          expect(json_response["with"].count).to eq 0
        end

        it "with correct number of host profiles without availability" do
          expect(json_response["without"].count).to eq 1
        end

        it "with correct host profiles without availability" do
          expect(json_response["without"][0]["id"]).to eq profile_another_user.id
        end
      end

      describe "according to that location and cat params" do
        before do
          get "/api/v1/host_profiles",
              params: {
                location: another_user.location,
                cats: 10,
                startDate: 1_588_032_000_000,
                endDate: 1_588_204_800_000
              }
        end

        it "with correct number of host profiles with availability" do
          expect(json_response["with"].count).to eq 0
        end

        it "with correct number of host profiles without availability" do
          expect(json_response["without"].count).to eq 0
        end
      end
    end
  end
end
