class Editorial::IndexController < AdminController
  # get /editorial
  def index
  end

  private

  def restrict_access
    require_user_group(:editors)
  end
end
