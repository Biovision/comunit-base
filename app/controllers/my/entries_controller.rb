class My::EntriesController < ApplicationController
  before_action :restrict_anonymous_access

  # get /my/entries
  def index
    @collection = Entry.page_for_owner(current_user, current_page)
  end
end
