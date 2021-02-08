RSpec::Benchmark.configure { |config| config.run_in_subprocess = true }

RSpec.describe ReviewsMailer, type: :mailer do
  let(:user) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker') }
  let(:host) { FactoryBot.create(:user, email: 'order@thestreets.com', nickname: 'Batman') }
  let!(:profile_host) { FactoryBot.create(:host_profile, user_id: host.id) }
  let(:booking) { FactoryBot.create(:booking, user_id: user.id, host_nickname: host.nickname) }
  let!(:review) do
    FactoryBot.create(:review, user_id: user.id, host_profile_id: profile_host.id, booking_id: booking.id, score: 2)
  end
  let(:new_review_mail) { ReviewsMailer.notify_host_create_review(host, booking, user, review) }
  let(:pending_review_1_day) { ReviewsMailer.notify_user_pending_review_1_day(host, user, booking) }
  let(:pending_review_3_days) { ReviewsMailer.notify_user_pending_review_3_days(host, user, booking) }
  let(:pending_review_10_days) { ReviewsMailer.notify_user_pending_review_10_days(host, user, booking) }

  describe 'notify_host_create_review' do
    it 'renders the subject' do
      expect(new_review_mail.subject).to eql('You got a new review!')
    end

    it 'renders the receiver email' do
      expect(new_review_mail.to).to eql([host.email])
    end

    it 'renders the sender email' do
      expect(new_review_mail.from).to eql('KattBNB meow-reply')
    end

    it 'contains basic review information' do
      expect(new_review_mail.body.encoded).to match("Hey, #{host.nickname}!")
      expect(new_review_mail.body.encoded).to match("#{user.nickname}")
      expect(new_review_mail.body.encoded).to match("#{review.score} out of 5")
    end

    it 'is performed under 600ms' do
      expect { new_review_mail }.to perform_under(600).ms.sample(20).times
    end

    it 'performs at least 800K iterations per second' do
      expect { new_review_mail }.to perform_at_least(800_000).ips
    end
  end

  describe 'notify_user_pending_review_1_day' do
    it 'renders the subject' do
      expect(pending_review_1_day.subject).to eql("Leave a review for #{host.nickname}")
    end

    it 'renders the receiver email' do
      expect(pending_review_1_day.to).to eql([user.email])
    end

    it 'renders the sender email' do
      expect(pending_review_1_day.from).to eql('KattBNB meow-reply')
    end

    it 'contains basic information' do
      expect(pending_review_1_day.body.encoded).to match("Hey, #{user.nickname}!")
      expect(pending_review_1_day.body.encoded).to match("#{host.nickname}")
      expect(pending_review_1_day.body.encoded).to match('We would like to encourage you to leave a review')
    end

    it 'is performed under 600ms' do
      expect { pending_review_1_day }.to perform_under(600).ms.sample(20).times
    end

    it 'performs at least 800K iterations per second' do
      expect { pending_review_1_day }.to perform_at_least(800_000).ips
    end
  end

  describe 'notify_user_pending_review_3_days' do
    it 'renders the subject' do
      expect(pending_review_3_days.subject).to eql("Leave a review for #{host.nickname}")
    end

    it 'renders the receiver email' do
      expect(pending_review_3_days.to).to eql([user.email])
    end

    it 'renders the sender email' do
      expect(pending_review_3_days.from).to eql('KattBNB meow-reply')
    end

    it 'contains basic information' do
      expect(pending_review_3_days.body.encoded).to match("Hey, #{user.nickname}!")
      expect(pending_review_3_days.body.encoded).to match("#{host.nickname}")
      expect(pending_review_3_days.body.encoded).to match(
        "We don't mean to spam you but we really would like to know what you think about your recent booking"
      )
    end

    it 'is performed under 600ms' do
      expect { pending_review_3_days }.to perform_under(600).ms.sample(20).times
    end

    it 'performs at least 800K iterations per second' do
      expect { pending_review_3_days }.to perform_at_least(800_000).ips
    end
  end

  describe 'notify_user_pending_review_10_days' do
    it 'renders the subject' do
      expect(pending_review_10_days.subject).to eql("Leave a review for #{host.nickname}")
    end

    it 'renders the receiver email' do
      expect(pending_review_10_days.to).to eql([user.email])
    end

    it 'renders the sender email' do
      expect(pending_review_10_days.from).to eql('KattBNB meow-reply')
    end

    it 'contains basic information' do
      expect(pending_review_10_days.body.encoded).to match("Hey, #{user.nickname}!")
      expect(pending_review_10_days.body.encoded).to match("#{host.nickname}")
      expect(pending_review_10_days.body.encoded).to match('Positive or negative feedback - we want to hear it!')
      expect(pending_review_10_days.body.encoded).to match(
        'If you have feedback you are not comfortable sharing on kattbnb.se you are always welcome to reach out to us via'
      )
    end

    it 'is performed under 600ms' do
      expect { pending_review_10_days }.to perform_under(600).ms.sample(20).times
    end

    it 'performs at least 800K iterations per second' do
      expect { pending_review_10_days }.to perform_at_least(800_000).ips
    end
  end
end
