# frozen_string_literal: true

# Impeachment and candidates
class ImpeachmentController < ApplicationController
  # get /impeachment/candidates
  def candidates
    @filter = params[:filter] || {}
    @collection = Candidate.filtered(@filter).list_for_visitors.distinct.page(current_page)
  end

  # get /impeachment/candidates/:id
  def candidate
    @entity = Candidate.find(params[:id])
  end
end
