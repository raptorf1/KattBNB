RSpec.describe "POST /api/v1/stripe_actions/receive_webhooks", type: :request do
  let(:headers) { { HTTP_ACCEPT: "application/json" } }

  describe "unsuccessfully" do
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

      it "with correct number of e-mails sheduled to be sent" do
        expect(Delayed::Job.all.length).to eq 1
      end

      it "with correct e-mail method invoked" do
        expect(Delayed::Job.first.handler.include?("notify_stripe_webhook_dispute_fraud")).to eq true
      end
    end
  end
end
