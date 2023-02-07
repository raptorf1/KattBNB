class ContactusMailer < ApplicationMailer
  def send_visitor_message(name, email, message)
    @name = name
    @email = email
    @message = message

    mail(
      to: Rails.env == "production" ? "zane@kattbnb.se" : "raptor_f1@hotmail.com",
      subject: "New visitor message from contact-us form"
    )
  end
end
