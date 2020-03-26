class ApplicationMailer < ActionMailer::Base

  default from: I18n.t('mailers.sender_kattbnb')
  layout 'mailer'

end
