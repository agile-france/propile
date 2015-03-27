class AccountMailer < ActionMailer::Base
  default from: Propile::Application.mail_sender

  def confirmation( account )
    @account = account
    mail to: account.email
  end
end
