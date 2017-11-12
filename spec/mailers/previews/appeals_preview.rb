# Preview all emails at http://localhost:3000/rails/mailers/appeals
class AppealsPreview < ActionMailer::Preview
  def appeal_reply
    AppealsMailer.appeal_reply(Appeal.last)
  end
end
