module MailerService
  def self.get_date(number)
    Time.at(number / 1000)
  end
end
