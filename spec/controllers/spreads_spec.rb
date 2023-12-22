require 'rails_helper'
require 'webmock/rspec'
require_relative '../support/api_responses'

RSpec.describe Api::V1::SpreadsController, type: :controller do
  before do
    stub_request(:get, "https://www.buda.com/api/v2/markets").
    to_return(status: 200, body: ApiResponses::MARKETS_RESPONSE)

    stub_request(:get, /https:\/\/www.buda.com\/api\/v2\/markets\/.*\/ticker/).
    to_return(status: 200, body: ApiResponses::TICKER_RESPONSE)
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
      expect(JSON.parse(response.body)['spreads']).not_to be_empty
    end
  end

  describe 'GET #show' do
  it 'returns a success response' do
    get :show, params: { id: 'BTC-COP' }
    expect(response).to be_successful, "Expected successful response but got #{response.status} with body #{response.body}"
    expect(JSON.parse(response.body)['market']).to eq('BTC-COP')
  end
end

describe 'POST #create_alert' do
  it 'creates a new alert and returns a success message' do
    post :create_alert, params: { id: 'BTC-CLP', target_spread: '5000' }
    expect(response).to be_successful
    expect(JSON.parse(response.body)['message']).to eq('Spread alert created successfully')
    expect(JSON.parse(response.body)['market']).to eq('BTC-CLP')
    expect(JSON.parse(response.body)['target_spread']).to eq('5000')
  end
end

describe 'GET #poll_alert' do
  it 'returns the status of an alert' do
    post :create_alert, params: { id: 'BTC-CLP', target_spread: '5000' }
    get :poll_alert, params: { id: 'BTC-CLP' }
    expect(response).to be_successful
    expect(JSON.parse(response.body)).to have_key('alert_triggered')
    expect(JSON.parse(response.body)).to have_key('current_spread')
    expect(JSON.parse(response.body)).to have_key('target_spread')
  end
end

describe 'GET #show' do
  it 'returns an error when given an invalid market' do
    get :show, params: { id: 'INVALID-MARKET' }
    expect(response).to have_http_status(:unprocessable_entity)
    expect(JSON.parse(response.body)['error']).to eq('Invalid market')
  end
end
end