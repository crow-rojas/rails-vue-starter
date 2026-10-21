class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "app@localhost")
  layout "mailer"
end
