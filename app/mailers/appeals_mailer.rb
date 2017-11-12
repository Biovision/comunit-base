class AppealsMailer < ApplicationMailer
  # На обращение пользователя дан ответ
  #
  # @param [Integer] appeal_id
  def appeal_reply(appeal_id)
    @appeal = Appeal.find_by(id: appeal_id)

    return if @appeal.nil? || @appeal.email.blank?

    mail to: @appeal.email
  end
end
