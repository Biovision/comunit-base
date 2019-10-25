# frozen_string_literal: true

# Searching for posts
class SearchController < ApplicationController
  # get /search?q=
  def index
    q = param_from_request(:q).to_s[0..100]
    @collection = q.blank? ? [] : Post.pg_search(q).list_for_visitors.first(50)
  end
end
