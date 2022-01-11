describe 'rake reviews:delete_unassociated_reviews', type: :task do
  let(:user) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let(:host) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }

  let!(:profile) { FactoryBot.create(:host_profile, user_id: host.id) }

  let(:booking) { FactoryBot.create(:booking, status: 'accepted', user_id: user.id, host_nickname: host.nickname) }
  let!(:review) { FactoryBot.create(:review, user_id: user.id, host_profile_id: profile.id, booking_id: booking.id) }

  let(:booking2) { FactoryBot.create(:booking, status: 'accepted', user_id: user.id, host_nickname: host.nickname) }
  let!(:review2) { FactoryBot.create(:review, user_id: user.id, host_profile_id: profile.id, booking_id: booking2.id) }

  it 'successfully preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  describe 'successfully' do
    before do
      review.update_attribute(:user_id, nil)
      review.update_attribute(:booking_id, nil)
      review.update_attribute(:host_profile_id, nil)
      @subject = task.execute
    end

    it 'runs gracefully with no errors' do
      expect { @subject }.not_to raise_error
    end

    it 'logs to stdout' do
      expect(@std_output).to eq("1 unassociated review(s) successfully deleted!\n")
    end
  end
end
