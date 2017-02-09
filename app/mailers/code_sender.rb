class CodeSender < ApplicationMailer
  def email(code)
    @code = code

    mail to: code.user.email
  end

  def password(code)
    @code = code

    mail to: code.user.email
  end
end
