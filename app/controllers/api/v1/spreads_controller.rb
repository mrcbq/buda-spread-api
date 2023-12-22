require 'net/http'
require 'json'

class Api::V1::SpreadsController < ApplicationController
  def index
    render json: calculate_spreads(get_active_markets)
  end

  def show
    render json: calculate_spread(params[:id])
  end

  private

  def get_active_markets
    response = HTTParty.get('https://www.buda.com/api/v2/markets')
    markets = JSON.parse(response.body)['markets']
    markets.map { |market| market['id'] unless market['disabled'] }.compact
  end
  
  def get_order_book(market)
    response = HTTParty.get("https://www.buda.com/api/v2/markets/#{market}/order_book")
    order_book = JSON.parse(response.body) #hash
  end

  def calculate_spread(market)
    order_book = get_order_book(market)
    lower_ask = order_book['order_book']['asks'][0][0].to_f
    higher_bid = order_book['order_book']['bids'][0][0].to_f
    spread = lower_ask - higher_bid
    { market: market, spread: spread }
  end

  def calculate_spreads(markets)
    spreads = markets.map { |market| calculate_spread(market) }
    {spreads: spreads}
  end
end

