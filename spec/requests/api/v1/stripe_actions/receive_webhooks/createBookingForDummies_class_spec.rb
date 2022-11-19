RSpec.describe "POST /api/v1/stripe_actions/receive_webhooks", type: :request do
  let!(:headers) { { HTTP_ACCEPT: "application/json" } }

  let!(:host) { FactoryBot.create(:user) }
  let!(:host_profile) { FactoryBot.create(:host_profile, user_id: host.id) }

  let!(:cat_owner) { FactoryBot.create(:user) }

  let!(:booking) do
    FactoryBot.create(
      :booking,
      host_nickname: host.nickname,
      user_id: cat_owner.id,
      dates: [1_562_803_200_000, 1_563_062_400_000, 1_666_915_200_000],
      payment_intent_id: "pi_000000000000000000000000",
      status: "accepted"
    )
  end

  describe "testing CreateBookingForDummies class" do
    before { Delayed::Worker.delay_jobs = false }
    after { Delayed::Worker.delay_jobs = true }

    describe "when booking already exists" do
      before do
        file =
          FileService.generate_charge_succeeded_stripe_event(
            "1666915200000,1667001600000,1667088000000,1667174400000,1667260800000,1667347200000,1667433600000",
            "JackTheReaper",
            cat_owner.id,
            booking.payment_intent_id
          )
        post "/api/v1/stripe_actions/receive_webhooks", params: file, headers: headers
      end

      it "with correct log message" do
        expect(@std_output).to eq("Booking already exists! Show me the moneyyyyy!")
      end
    end

    describe "when booking does not exist" do
      describe "and host does not exist in the database" do
        before do
          file =
            FileService.generate_charge_succeeded_stripe_event(
              "1666915200000,1667433600000",
              "NotExistingHost",
              cat_owner.id,
              "pi_000000000000000000000001"
            )
          post "/api/v1/stripe_actions/receive_webhooks", params: file, headers: headers
        end

        it "with correct number of bookings in the database" do
          expect(Booking.all.length).to eq 1
        end

        it "with correct booking ID in the database" do
          expect(Booking.all.first.id).to eq booking.id
        end

        it "with correct log message when cancelling the payment intent" do
          expect(@std_output).to match("No such payment_intent:")
        end
      end

      describe "and booking is not persisted (no dates provided)" do
        before do
          file =
            FileService.generate_charge_succeeded_stripe_event(
              "",
              host.nickname,
              cat_owner.id,
              "pi_000000000000000000000001"
            )
          post "/api/v1/stripe_actions/receive_webhooks", params: file, headers: headers
        end

        it "with correct number of bookings in the database" do
          expect(Booking.all.length).to eq 1
        end

        it "with correct booking ID in the database" do
          expect(Booking.all.first.id).to eq booking.id
        end

        it "with correct log message when cancelling the payment intent" do
          expect(@std_output).to match("No such payment_intent:")
        end
      end

      describe "and booking is created but host already has an accepted upcoming booking in those dates in the database so it gets deleted" do
        before do
          booking.update(dates: booking.dates.push(4_133_973_599_999))
          file =
            FileService.generate_charge_succeeded_stripe_event(
              "1666915200000,1667433600000",
              host.nickname,
              cat_owner.id,
              "pi_000000000000000000000001"
            )
          post "/api/v1/stripe_actions/receive_webhooks", params: file, headers: headers
        end

        it "with correct number of bookings in the database" do
          expect(Booking.all.length).to eq 1
        end

        it "with correct booking ID in the database" do
          expect(Booking.all.first.id).to eq booking.id
        end

        it "with correct log message when cancelling the payment intent" do
          expect(@std_output).to match("No such payment_intent:")
        end
      end

      describe "and booking is successfully created (a booking already exists in the database)" do
        before do
          file =
            FileService.generate_charge_succeeded_stripe_event(
              "1672560000000,1674248400000",
              host.nickname,
              cat_owner.id,
              "pi_000000000000000000000001"
            )
          post "/api/v1/stripe_actions/receive_webhooks", params: file, headers: headers
        end

        it "with correct number of bookings in the database" do
          expect(Booking.all.length).to eq 2
        end

        it "with correct booking ID in the database for the existing booking" do
          expect(Booking.all.first.id).to eq booking.id
        end

        it "with correct booking ID in the database for the newly created booking" do
          expect(Booking.all.last.id).to_not eq booking.id
        end

        it "with 2 bookings not sharing the same ID" do
          expect(Booking.all.first.id).to_not eq Booking.all.last.id
        end
      end

      describe "and booking is successfully created (no booking exists in the database)" do
        before do
          Booking.destroy_all
          file =
            FileService.generate_charge_succeeded_stripe_event(
              "1672560000000,1674248400000",
              host.nickname,
              cat_owner.id,
              "pi_000000000000000000000001"
            )
          post "/api/v1/stripe_actions/receive_webhooks", params: file, headers: headers
        end

        it "with correct number of bookings in the database" do
          expect(Booking.all.length).to eq 1
        end

        it "with correct booking status in the database for the newly created booking" do
          expect(Booking.last.status).to eq "pending"
        end
      end
    end
  end
end
