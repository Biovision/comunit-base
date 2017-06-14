class Editorial::IndexController < AdminController
  # get /editorial
  def index
  end

  private

  def restrict_access
    require_privilege_group(:editors)
  end
end
