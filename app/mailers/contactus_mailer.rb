class ContactusMailer < ApplicationMailer
  def send_visitor_message(name, email, message)
    @name = name
    @email = email
    @message = message

    mail(
      to: Rails.env == "production" ? "zane@kattbnb.se" : "kattbnb@gmail.com",
      subject: "New visitor message from contact-us form"
    )
  end
end
