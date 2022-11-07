RSpec.describe "POST /api/v1/stripe_actions/receive_webhooks", type: :request do
  let(:headers) { { HTTP_ACCEPT: "application/json" } }

  let(:host) { FactoryBot.create(:user) }
  let(:host_profile) { FactoryBot.create(:host_profile, user_id: host.id) }

  let(:cat_owner) { FactoryBot.create(:user) }

  let!(:booking) do
    FactoryBot.create(
      :booking,
      host_nickname: host.nickname,
      user_id: cat_owner.id,
      dates: [1_562_803_200_000, 1_563_062_400_000],
      payment_intent_id: "pi_000000000000000000000000"
    )
  end

  describe "testing CreateBookingForDummies class" do
    before { Delayed::Worker.delay_jobs = false }
    after { Delayed::Worker.delay_jobs = true }

    describe "when booking already exists" do
      before do
        file =
          FileService.generate_charge_succeeded_stripe_event(
            "1666915200000,1667001600000,1667088000000,1667174400000,1667260800000,1667347200000,1667433600000"
          )
        post "/api/v1/stripe_actions/receive_webhooks", params: file, headers: headers
      end

      it "with correct log message" do
        expect(@std_output).to eq("Booking already exists! Show me the moneyyyyy!")
      end
    end

    describe "when booking does not exist" do
      before { Booking.destroy_all }

      describe "and during creation is not persisted" do
        before do
          file = FileService.generate_charge_succeeded_stripe_event("")
          post "/api/v1/stripe_actions/receive_webhooks", params: file, headers: headers
        end

        it "with correct number of bookings in the database" do
          expect(Booking.all.length).to eq 0
        end
      end

      describe "and is created but host does not exist in the database" do
        before do
          file = FileService.generate_charge_succeeded_stripe_event("1666915200000,1667433600000")
          post "/api/v1/stripe_actions/receive_webhooks", params: file, headers: headers
        end

        it "with correct number of bookings in the database" do
          expect(Booking.all.length).to eq 0
        end
      end
    end
  end
end
