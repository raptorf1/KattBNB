RSpec.describe "POST /api/v1/stripe_actions/receive_webhooks", type: :request do
  let(:headers) { { HTTP_ACCEPT: "application/json" } }

  describe "successfully" do
    describe "for a charge_succeeded event when all dates are present" do
      before do
        file =
          FileService.generate_charge_succeeded_stripe_event(
            "1666915200000,1667001600000,1667088000000,1667174400000,1667260800000,1667347200000,1667433600000",
            "JackTheReaper",
            3,
            "pi_000000000000000000000000"
          )
        post "/api/v1/stripe_actions/receive_webhooks", params: file, headers: headers
      end

      it "with relevant message" do
        expect(json_response["message"]).to eq "Success!"
      end

      it "with 200 status" do
        expect(response.status).to eq 200
      end

      it "with correct number of jobs scheduled" do
        expect(Delayed::Job.all.length).to eq 1
      end

      it "with correct method invoked" do
        expect(
          Delayed::Job.first.handler.include?(
            "Api::V1::StripeActions::ReceiveWebhooksController::CreateBookingForDummies"
          )
        ).to eq true
      end

      it "with correct dates" do
        expect(
          Delayed::Job.first.handler.include?(
            "\n- 1666915200000\n- 1667001600000\n- 1667088000000\n- 1667174400000\n- 1667260800000\n- 1667347200000\n- 1667433600000\n"
          )
        ).to eq true
      end
    end

    describe "for a charge_succeeded event when only 2 dates are present" do
      before do
        file =
          FileService.generate_charge_succeeded_stripe_event(
            "1666915200000,1667433600000",
            "JackTheReaper",
            3,
            "pi_000000000000000000000000"
          )
        post "/api/v1/stripe_actions/receive_webhooks", params: file, headers: headers
      end

      it "with relevant message" do
        expect(json_response["message"]).to eq "Success!"
      end

      it "with 200 status" do
        expect(response.status).to eq 200
      end

      it "with correct number of jobs scheduled" do
        expect(Delayed::Job.all.length).to eq 1
      end

      it "with correct method invoked" do
        expect(
          Delayed::Job.first.handler.include?(
            "Api::V1::StripeActions::ReceiveWebhooksController::CreateBookingForDummies"
          )
        ).to eq true
      end

      it "with correct dates" do
        expect(
          Delayed::Job.first.handler.include?(
            "\n- 1666915200000\n- 1667001600000\n- 1667088000000\n- 1667174400000\n- 1667260800000\n- 1667347200000\n- 1667433600000\n"
          )
        ).to eq true
      end
    end

    describe "for a charge_dispute_created event" do
      before do
        post "/api/v1/stripe_actions/receive_webhooks",
             params: File.open("spec/fixtures/stripe_webhook_events/charge_dispute_created.json"),
             headers: headers
      end

      it "with relevant message" do
        expect(json_response["message"]).to eq "Success!"
      end

      it "with 200 status" do
        expect(response.status).to eq 200
      end

      it "with correct number of e-mail scheduled to be sent" do
        expect(Delayed::Job.all.length).to eq 1
      end

      it "with correct e-mail method invoked" do
        expect(Delayed::Job.first.handler.include?("notify_stripe_webhook_dispute_fraud")).to eq true
      end
    end

    describe "for an issuing_dispute_created event" do
      before do
        post "/api/v1/stripe_actions/receive_webhooks",
             params: File.open("spec/fixtures/stripe_webhook_events/issuing_dispute_created.json"),
             headers: headers
      end

      it "with relevant message" do
        expect(json_response["message"]).to eq "Success!"
      end

      it "with 200 status" do
        expect(response.status).to eq 200
      end

      it "with correct number of e-mail scheduled to be sent" do
        expect(Delayed::Job.all.length).to eq 1
      end

      it "with correct e-mail method invoked" do
        expect(Delayed::Job.first.handler.include?("notify_stripe_webhook_dispute_fraud")).to eq true
      end
    end

    describe "for a radar_early_fraud_warning_created event" do
      before do
        post "/api/v1/stripe_actions/receive_webhooks",
             params: File.open("spec/fixtures/stripe_webhook_events/radar_early_fraud_warning_created.json"),
             headers: headers
      end

      it "with relevant message" do
        expect(json_response["message"]).to eq "Success!"
      end

      it "with 200 status" do
        expect(response.status).to eq 200
      end

      it "with correct number of e-mail scheduled to be sent" do
        expect(Delayed::Job.all.length).to eq 1
      end

      it "with correct e-mail method invoked" do
        expect(Delayed::Job.first.handler.include?("notify_stripe_webhook_dispute_fraud")).to eq true
      end
    end

    describe "for an event we do not monitor" do
      before do
        post "/api/v1/stripe_actions/receive_webhooks",
             params: File.open("spec/fixtures/stripe_webhook_events/subscription_schedule_created.json"),
             headers: headers
      end

      it "with relevant message" do
        expect(json_response["message"]).to eq "Success!"
      end

      it "with 200 status" do
        expect(response.status).to eq 200
      end

      it "with correct log message" do
        expect(@std_output).to eq(
          "Unhandled event type: subscription_schedule.created. Why are we receiving this again???"
        )
      end
    end
  end

  describe "unsuccessfully" do
    describe "for a JSON parse error" do
      before do
        post "/api/v1/stripe_actions/receive_webhooks",
             params: "{\n  \"id\": \"evt_00000000000000000  \}",
             headers: headers
      end

      it "with relevant message" do
        expect(json_response["message"]).to eq "Success!"
      end

      it "with 200 status" do
        expect(response.status).to eq 200
      end

      it "with correct log message" do
        expect(@std_output).to match("unexpected token at")
      end

      it "with correct number of e-mail scheduled to be sent" do
        expect(Delayed::Job.all.length).to eq 1
      end

      it "with correct e-mail method invoked" do
        expect(Delayed::Job.first.handler.include?("notify_stripe_webhook_error")).to eq true
      end

      it "with correct e-mail arguments" do
        expect(Delayed::Job.first.handler.include?("Webhook JSON Parse Error")).to eq true
      end
    end
  end
end
