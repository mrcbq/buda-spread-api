require 'net/http'

class Api::V1::SpreadsController < ApplicationController
  cattr_accessor :spread_alerts

  before_action :sanitize_params, only: [:show, :poll_alert, :create_alert]

  def index
    @spreads = calculate_spreads(get_active_markets)
    render json: { spreads: @spreads }
  end

  def show
    @spread = calculate_spread(params[:id])
    render json: @spread
  end

  def create_alert
    market = params[:id]
    target_spread = params[:target_spread]
  
    self.class.spread_alerts ||= {}
    self.class.spread_alerts[market] = target_spread.to_f
  
    render json: { message: 'Spread alert created successfully', market: market, target_spread: target_spread }
  end
  
  def poll_alert
    market = params[:id]
    current_spread = calculate_spread(params[:id])[:spread]
  
    target_spread = self.class.spread_alerts&.[](market)
  
    if target_spread
      render json: { alert_triggered: current_spread > target_spread, current_spread: current_spread, target_spread: target_spread }
    else
      render json: { error: 'No spread alert found for the specified market' }, status: :not_found
    end
  end

  private
  
  def sanitize_params
    market = params[:id]
    active_markets = get_active_markets

    unless active_markets.include?(market)
      render json: { error: 'Invalid market' }, status: :unprocessable_entity
    end
  end

  def get_active_markets
    response = HTTParty.get('https://www.buda.com/api/v2/markets')
    markets = JSON.parse(response.body)['markets']
    markets.map { |market| market['id'] unless market['disabled'] }.compact
  end
  
  def get_ticker(market)
    response = HTTParty.get("https://www.buda.com/api/v2/markets/#{market}/ticker")
    ticker = JSON.parse(response.body) #hash
  end

  def calculate_spread(market)
    ticker = get_ticker(market)
    lower_ask = ticker['ticker']['min_ask'].first.to_f
    higher_bid = ticker['ticker']['max_bid'].first.to_f
    spread = lower_ask - higher_bid
    { market: market, spread: spread }
  end

  def calculate_spreads(markets)
    spreads = markets.map { |market| calculate_spread(market) }
  end
end

