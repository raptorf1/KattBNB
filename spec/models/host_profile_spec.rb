RSpec::Benchmark.configure do |config|
  config.run_in_subprocess = true
end

RSpec.describe HostProfile, type: :model do
  it 'should have valid Factory' do
    expect(create(:host_profile)).to be_valid
  end

  describe 'Database table' do
    it { is_expected.to have_db_column :description }
    it { is_expected.to have_db_column :full_address }
    it { is_expected.to have_db_column :price_per_day_1_cat }
    it { is_expected.to have_db_column :supplement_price_per_cat_per_day }
    it { is_expected.to have_db_column :max_cats_accepted }
    it { is_expected.to have_db_column :availability }
    it { is_expected.to have_db_column :lat }
    it { is_expected.to have_db_column :long }
    it { is_expected.to have_db_column :latitude }
    it { is_expected.to have_db_column :longitude }
    it { is_expected.to have_db_column :score }
    it { is_expected.to have_db_column :stripe_state }
    it { is_expected.to have_db_column :stripe_account_id }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_presence_of :full_address }
    it { is_expected.to validate_presence_of :price_per_day_1_cat }
    it { is_expected.to validate_presence_of :supplement_price_per_cat_per_day }
    it { is_expected.to validate_presence_of :max_cats_accepted }
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'Relations' do
    it { is_expected.to have_many(:review) }
  end

  describe 'Default values' do
    it 'returns Array as class for availability field' do
      FactoryBot.create(:host_profile)
      expect(HostProfile.last.availability.class).to eq Array
    end
  end

  describe 'Delete dependent setting' do
    it 'profile is deleted when associated user is deleted from the database' do
      FactoryBot.create(:host_profile)
      expect(HostProfile.all.length).to eq 1
      expect(User.all.length).to eq 1
      User.last.destroy
      expect(HostProfile.all.length).to eq 0
      expect(User.all.length).to eq 0
    end

    it 'performance stats for user deletion with host profile' do
      FactoryBot.create(:host_profile)
      user = HostProfile.last.user
      expect { user.destroy }.to perform_under(150).ms.sample(20).times
      expect { user.destroy }.to perform_at_least(100).ips
    end

    it 'user is not deleted when associated profile is deleted from the database' do
      FactoryBot.create(:host_profile)
      expect(HostProfile.all.length).to eq 1
      expect(User.all.length).to eq 1
      HostProfile.last.destroy
      expect(HostProfile.all.length).to eq 0
      expect(User.all.length).to eq 1
    end

    it 'performance stats of host profile deletion' do
      profile = FactoryBot.create(:host_profile)
      expect { profile.destroy }.to perform_under(50).ms.sample(20).times
      expect { profile.destroy }.to perform_at_least(300).ips
    end

    it 'review is nullified when associated host profile is deleted' do
      user = FactoryBot.create(:user, email: 'george@mail.com', nickname: 'Alonso')
      host = FactoryBot.create(:user, email: 'zane@mail.com', nickname: 'Kitten')
      profile = FactoryBot.create(:host_profile, user_id: host.id)
      booking = FactoryBot.create(:booking, host_nickname: host.nickname, user_id: user.id, status: 'accepted', dates: [1462889600000, 1462976000000])
      review = FactoryBot.create(:review, user_id: user.id, host_profile_id: profile.id, booking_id: booking.id)
      profile.destroy
      review.reload
      expect(review.host_profile_id).to eq nil
    end

    it 'performance stats for review is nullified when associated host profile is deleted' do
      user = FactoryBot.create(:user, email: 'george@mail.com', nickname: 'Alonso')
      host = FactoryBot.create(:user, email: 'zane@mail.com', nickname: 'Kitten')
      profile = FactoryBot.create(:host_profile, user_id: host.id)
      booking = FactoryBot.create(:booking, host_nickname: host.nickname, user_id: user.id, status: 'accepted', dates: [1462889600000, 1462976000000])
      review = FactoryBot.create(:review, user_id: user.id, host_profile_id: profile.id, booking_id: booking.id)
      expect { profile.destroy }.to perform_under(50).ms.sample(20).times
      expect { profile.destroy }.to perform_at_least(300).ips
    end

  end
end
