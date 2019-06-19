class SearchController < ApplicationController
  # get /search?q=
  def index
    @query = param_from_request(:q).to_s[0..100]
    if @query.blank?
      @collection = []
    else
      @collection = Elasticsearch::Model.search(@query, Post).records.first(20)
    end
  end
end
