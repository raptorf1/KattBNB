RSpec.describe "GET /api/v1/contact_us", type: :request do
  describe "succesfully" do
    before do
      get "/api/v1/contact_us",
          params: {
            name: "John Doe",
            email: "test@hotmail.com",
            message: "Can I order pizza from your website???"
          }
    end

    it "with 200 status" do
      expect(response.status).to eq 200
    end

    it "with relevant message" do
      expect(json_response["message"]).to eq "Success!!!"
    end

    it "with correct number of emails sent to website admin" do
      expect(Delayed::Job.all.count).to eq 1
    end
  end

  describe "unsuccessfully" do
    describe "if message characters exceed the 1000 limit" do
      before do
        get "/api/v1/contact_us",
            params: {
              name: "John Doe",
              email: "test@hotmail.com",
              message:
                "Can I order pizza from your website??? Can I order pizza from your website??? Can I order pizza from your website??? Can I order pizza from your website??? Can I order pizza from your website??? Can I order pizza from your website??? Can I order pizza from your website??? Can I order pizza from your website??? Can I order pizza from your website??? Can I order pizza from your website??? Can I order pizza from your website??? Can I order pizza from your website??? Can I order pizza from your website??? Can I order pizza from your website??? Can I order pizza from your website??? Can I order pizza from your website??? Can I order pizza from your website??? Can I order pizza from your website??? Can I order pizza from your website??? Can I order pizza from your website??? Can I order pizza from your website??? Can I order pizza from your website??? Can I order pizza from your website??? Can I order pizza from your website??? Can I order pizza from your website??? Can I order pizza from your website???"
            }
      end

      it "with 422 status" do
        expect(response.status).to eq 422
      end

      it "with relevant error" do
        expect(json_response["error"]).to eq ["Your message cannot exceed 1000 characters!"]
      end
    end

    describe "if name characters exceed the 100 limit" do
      before do
        get "/api/v1/contact_us",
            params: {
              name:
                "John Doe John Doe John Doe John Doe John Doe John Doe John Doe John Doe John Doe John Doe John Doe John Doe John Doe John Doe John Doe",
              email: "test@hotmail.com",
              message: "Can I order pizza from your website???"
            }
      end

      it "with 422 status" do
        expect(response.status).to eq 422
      end

      it "with relevant error" do
        expect(json_response["error"]).to eq ["Your name cannot exceed 100 characters!"]
      end
    end

    describe "if email is invalid" do
      before do
        get "/api/v1/contact_us",
            params: {
              name: "John Doe",
              email: "test@fakeeeeeemail.com",
              message: "Can I order pizza from your website???"
            }
      end

      it "with 422 status" do
        expect(response.status).to eq 422
      end

      it "with relevant error" do
        expect(json_response["error"]).to eq [
             "There was a problem validating your email! Are you sure it's the right one? You can always find us by following our social media links below."
           ]
      end
    end
  end
end
