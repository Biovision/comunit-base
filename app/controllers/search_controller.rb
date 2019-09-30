class SearchController < ApplicationController
  # get /search?q=
  def index
    @query = param_from_request(:q).to_s[0..100]
    if @query.blank?
      @collection = []
    else
      @collection = Post.pg_search(@query).list_for_visitors.first(50)
    end
  end
end
