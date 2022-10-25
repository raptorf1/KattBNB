RSpec.describe ContactusMailer, type: :mailer do
  let(:new_visitor_message) do
    ContactusMailer.send_visitor_message("Richard Dragon", "rdrag@drop.nl", "A question for the website owners!")
  end

  it "renders the subject" do
    expect(new_visitor_message.subject).to eql("New visitor message from contact-us form")
  end

  it "renders the receiver email" do
    expect(new_visitor_message.to).to eql(["george@kattbnb.se"])
  end

  it "renders the sender email" do
    expect(new_visitor_message.from).to eql("KattBNB meow-reply")
  end

  it "contains visitor input" do
    expect(new_visitor_message.body.encoded).to match("Richard Dragon").and match("rdrag@drop.nl").and match(
                  "A question for the website owners!"
                )
  end
end
