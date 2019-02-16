require 'mail'

class SendGmail
  def initialize(user_name, password)
    @user_name = user_name
    @password = password
  end

  def deliver(from, to, subject, body)
    mail = Mail.new

    options = { address: "smtp.gmail.com",
                port: 587,
                domain: "smtp.gmail.com",
                user_name: @user_name,
                password: @password,
                authentication: :plain,
                enable_starttls_auto: true  }
    mail.charset = 'utf-8'
    mail.from from
    mail.to to
    mail.subject subject
    mail.body body
    mail.delivery_method(:smtp, options)
    mail.deliver
  end
end
