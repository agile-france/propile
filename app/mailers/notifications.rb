class Notifications < ActionMailer::Base
 
  FromAddress = Propile::Application.mail_sender
  default from: FromAddress
  helper :application

  def account_reset(account)
    @account = account
    mail to: account.email, :subject => Propile::Application.mail_subject_prefix + I18n.t('notifications.password_reset.subject')
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.session_submit.subject
  #
  def session_submit(presenter, session)
    @greeting = "Bonjour"
    @login_guid = presenter.account.authentication_token
    @session = session
    mail to: presenter.email, :subject => Propile::Application.mail_subject_prefix + I18n.t('notifications.session_submit.subject')
  end

  def review_creation(email, review)
    @review = review
    @session= review.session
    mail to: email, :subject => Propile::Application.mail_subject_prefix + "Nouvelle revue pour la session '#{review.session.title}'"
  end

  def comment_creation(email, comment)
    @review = comment.review
    @comment = comment
    @session= @review.session
    mail to: email, :subject => Propile::Application.mail_subject_prefix + "Un commentaire a été déposé pour la revue sur la session '#{@session.title}'"
  end
  
end
