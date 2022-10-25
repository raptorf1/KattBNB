describe "rake reviews:delete_unassociated_reviews", type: :task do
  let!(:review) { FactoryBot.create(:review) }
  let!(:other_review) { FactoryBot.create(:review) }

  it "successfully preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end

  describe "successfully" do
    before do
      review.update_attribute(:user_id, nil)
      review.update_attribute(:booking_id, nil)
      review.update_attribute(:host_profile_id, nil)
      @subject = task.execute
    end

    it "runs with no errors" do
      expect { @subject }.not_to raise_error
    end

    it "logs to stdout" do
      expect(@std_output).to eq("Unassociated review with id #{review.id} successfully deleted!")
    end
  end
end
