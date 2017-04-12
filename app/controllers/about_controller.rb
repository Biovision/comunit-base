class AboutController < ApplicationController
  # get /about
  def index
    @editable_page = EditablePage.find_by(slug: 'about')
  end

  # get /donate
  def donate
    @editable_page = EditablePage.find_by(slug: 'donate')
  end
end
