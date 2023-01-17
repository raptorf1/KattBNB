RSpec.describe "GET /api/v1/reviews", type: :request do
  let(:host_profile) { FactoryBot.create(:host_profile) }

  let!(:review_1) do
    FactoryBot.create(:review, host_profile_id: host_profile.id, created_at: "Thu, 01 Jan 2023 00:03:00 UTC +00:00")
  end
  let!(:review_2) do
    FactoryBot.create(:review, host_profile_id: host_profile.id, created_at: "Thu, 01 Jan 2023 00:06:00 UTC +00:00")
  end
  let!(:review_3) do
    FactoryBot.create(:review, host_profile_id: host_profile.id, created_at: "Thu, 01 Jan 2023 00:09:00 UTC +00:00")
  end

  describe "successfully" do
    before { get "/api/v1/reviews?host_profile_id=#{host_profile.id}" }

    it "returns correct number of reviews" do
      expect(json_response.count).to eq 3
    end

    it "returns 200 status" do
      expect(response.status).to eq 200
    end

    it "returns correct number of keys in the response" do
      expect(json_response.first.count).to eq 9
    end

    it "returns correct key names in the response" do
      expect(json_response.first).to include(
        "id",
        "score",
        "body",
        "host_reply",
        "host_nickname",
        "host_avatar",
        "created_at",
        "updated_at",
        "user"
      )
    end

    it "returns correct number of user keys in the response" do
      expect(json_response.first["user"].count).to eq 4
    end

    it "returns correct user key names in the response" do
      expect(json_response.first["user"]).to include("id", "location", "nickname", "profile_avatar")
    end

    it "returns reviews sorted correctly (newest created appears first)" do
      expect(json_response.first["id"]).to eq review_3.id
    end

    it "returns reviews sorted correctly (oldest created appears last)" do
      expect(json_response.last["id"]).to eq review_1.id
    end
  end
end
