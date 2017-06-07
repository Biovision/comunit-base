module UsersHelper
  def genders_for_select
    prefix  = 'activerecord.attributes.user.genders'
    genders = [[t(:not_selected), '']]
    genders + User.genders.keys.map { |o| [I18n.t("#{prefix}.#{o}"), o] }
  end

  def attitudes_for_select
    options = [[t(:not_selected), '']]
    options + (-2..1).map { |o| [t("attitudes.#{o.to_s}"), o]}
  end

  def marital_statuses_for_select(gender)
    prefix = 'activerecord.attributes.user.marital_statuses.'
    prefix << (gender.blank? ? 'default' : gender)
    options = [[t(:not_selected), '']]
    options + User.marital_statuses.keys.map { |o| [t("#{prefix}.#{o}"), o] }
  end

  def marital_status_for_user(user)
    prefix = 'activerecord.attributes.user.marital_statuses.'
    prefix << (user.gender.blank? ? 'default' : user.gender)
    t("#{prefix}.#{user.marital_status}", default: :not_selected)
  end

  # @param [User] user
  def user_link(user)
    if user.is_a? User
      if user.deleted?
        t(:anonymous)
      else
        text = user.profile_name
        link_to text, user_profile_path(slug: user.long_slug), class: "profile native"
      end
    else
      I18n.t(:anonymous)
    end
  end

  # @param [User] user
  def admin_user_link(user)
    if user.nil?
      t(:anonymous)
    else
      text = user.profile_name
      link_to text, admin_user_path(user.id), class: "profile native"
    end
  end

  # @param [User] user
  def editorial_user_link(user)
    if user.nil?
      t(:anonymous)
    else
      text = user.profile_name
      link_to text, editorial_user_path(user.id), class: 'profile'
    end
  end

  # @param [User] user
  def profile_avatar(user)
    if user.is_a?(User) && !user.image.blank? && !user.deleted?
      image_tag user.image.profile.url
    else
      image_tag('biovision/base/placeholders/user.svg')
    end
  end
end
