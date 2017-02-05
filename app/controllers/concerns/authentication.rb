module Authentication
  extend ActiveSupport::Concern

  def redirect_authenticated_user
    redirect_to root_path unless current_user.nil?
  end

  # @param [User] user
  # @param [Hash] tracking
  def create_token_for_user(user, tracking)
    token = user.tokens.create! tracking
    cookies['token'] = {
        value: token.cookie_pair,
        expires: 1.year.from_now,
        domain: :all,
        httponly: true
    }
  end

  # Authenticate user considering legacy password
  #
  # @param [User] user
  # @param [String] password
  def authenticate(user, password)
    if user.legacy_password.nil?
      user.authenticate password
    else
      salt = user.legacy_password[0..7]
      hash = user.legacy_password[8..39]
      if hash == Digest::MD5.hexdigest(salt + password)
        user.update password: password, password_confirmation: password, legacy_password: nil
      else
        false
      end
    end
  end
end
