RSpec.describe ReviewsMailer, type: :mailer do
  let(:review) { FactoryBot.create(:review, score: 2) }
  let(:new_review_mail) do
    ReviewsMailer.notify_host_create_review(review.host_profile.user, review.booking, review.user, review)
  end
  let(:pending_review_1_day) do
    ReviewsMailer.notify_user_pending_review_1_day(review.host_profile.user, review.user, review.booking)
  end
  let(:pending_review_3_days) do
    ReviewsMailer.notify_user_pending_review_3_days(review.host_profile.user, review.user, review.booking)
  end
  let(:pending_review_10_days) do
    ReviewsMailer.notify_user_pending_review_10_days(review.host_profile.user, review.user, review.booking)
  end

  describe 'notify_host_create_review' do
    before { User.destroy_all }

    it 'renders the subject' do
      expect(new_review_mail.subject).to eql('You got a new review!')
    end

    it 'renders the receiver email' do
      expect(new_review_mail.to).to eql([review.host_profile.user.email])
    end

    it 'renders the sender email' do
      expect(new_review_mail.from).to eql('KattBNB meow-reply')
    end

    it 'contains basic review information' do
      expect(new_review_mail.body.encoded).to match("Hey, #{review.host_profile.user.nickname}!").and match(
                                                                "#{review.user.nickname}"
                                                              ).and match("#{review.score} out of 5")
    end
  end

  describe 'notify_user_pending_review_1_day' do
    it 'renders the subject' do
      expect(pending_review_1_day.subject).to eql("Leave a review for #{review.host_profile.user.nickname}")
    end

    it 'renders the receiver email' do
      expect(pending_review_1_day.to).to eql([review.user.email])
    end

    it 'renders the sender email' do
      expect(pending_review_1_day.from).to eql('KattBNB meow-reply')
    end

    it 'contains basic information' do
      expect(pending_review_1_day.body.encoded).to match("Hey, #{review.user.nickname}!").and match(
                                                   "#{review.host_profile.user.nickname}"
                                                 ).and match('We would like to encourage you to leave a review')
    end
  end

  describe 'notify_user_pending_review_3_days' do
    it 'renders the subject' do
      expect(pending_review_3_days.subject).to eql("Leave a review for #{review.host_profile.user.nickname}")
    end

    it 'renders the receiver email' do
      expect(pending_review_3_days.to).to eql([review.user.email])
    end

    it 'renders the sender email' do
      expect(pending_review_3_days.from).to eql('KattBNB meow-reply')
    end

    it 'contains basic information' do
      expect(pending_review_3_days.body.encoded).to match("Hey, #{review.user.nickname}!").and match(
                                                   "#{review.host_profile.user.nickname}"
                                                 ).and match(
                                                                                                     "We don't mean to spam you but we really would like to know what you think about your recent booking"
                                                                                                   )
    end
  end

  describe 'notify_user_pending_review_10_days' do
    it 'renders the subject' do
      expect(pending_review_10_days.subject).to eql("Leave a review for #{review.host_profile.user.nickname}")
    end

    it 'renders the receiver email' do
      expect(pending_review_10_days.to).to eql([review.user.email])
    end

    it 'renders the sender email' do
      expect(pending_review_10_days.from).to eql('KattBNB meow-reply')
    end

    it 'contains basic information' do
      expect(pending_review_10_days.body.encoded).to match("Hey, #{review.user.nickname}!").and match(
                                                   "#{review.host_profile.user.nickname}"
                                                 ).and match(
                                                                                                     'Positive or negative feedback - we want to hear it!'
                                                                                                   ).and match(
                                                                                                                                                                      'If you have feedback you are not comfortable sharing on kattbnb.se you are always welcome to reach out to us via'
                                                                                                                                                                    )
    end
  end
end
