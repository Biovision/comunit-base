# frozen_string_literal: true

# Displaying trade unions
class TradeUnionsController < ApplicationController
  # get /trade_unions
  def index
    @collection = TradeUnion.page_for_visitors(current_page)
  end

  # get /trade_unions/:id-:slug
  def show
    @entity = TradeUnion.find_by(id: params[:id])

    handle_http_404('Cannot find trade union') if @entity.nil?
  end

  private

  def component_class
    Biovision::Components::TradeUnionsComponent
  end
end
