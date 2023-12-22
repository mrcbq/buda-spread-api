require 'swagger_helper'
require_relative '../support/api_responses'

RSpec.describe 'Spreads API', swagger_doc: 'v1/swagger.json', type: :request do

  before do
    stub_request(:get, "https://www.buda.com/api/v2/markets").
      to_return(status: 200, body: ApiResponses::MARKETS_RESPONSE)

    stub_request(:get, /https:\/\/www.buda.com\/api\/v2\/markets\/.*\/ticker/).
      to_return(status: 200, body: ApiResponses::TICKER_RESPONSE)
  end

  path '/api/v1/spreads' do

    get 'Retrieves all spreads' do
      tags 'Spreads'
      produces 'application/json'

      response '200', 'spreads found' do
        schema type: :object,
          properties: {
            spreads: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  market: { type: :string },
                  spread: { type: :number }
                },
                required: [ 'market', 'spread' ]
              }
            }
          },
          required: [ 'spreads' ]

        run_test!
      end
    end
  end

  path '/api/v1/spreads/{id}' do
    get 'Retrieves a spread' do
      tags 'Spreads'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string

      response '200', 'spread found' do
        let(:id) { 'BTC-CLP' }
        schema type: :object,
          properties: {
            market: { type: :string },
            spread: { type: :number }
          },
          required: [ 'market', 'spread' ]
        run_test!
      end

      response '422', 'spread not found' do
        let(:id) { 'INVALID-MARKET' }
        run_test!
      end
    end
  end

  path '/api/v1/spreads/{id}/create_alert' do

    post 'Creates a spread alert' do
      tags 'Spreads'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: :alert, in: :body, schema: {
        type: :object,
        properties: {
          target_spread: { type: :string }
        },
        required: [ 'target_spread' ]
      }

      response '200', 'alert created' do
        let(:id) { 'BTC-CLP' }
        let(:alert) { { target_spread: '5000' } }
        run_test!
      end

      response '422', 'spread not found' do
        let(:id) { 'INVALID-MARKET' }
        let(:alert) { { target_spread: '5000' } }
        run_test!
      end
    end
  end

  path '/api/v1/spreads/{id}/poll_alert' do
    get 'Polls a spread alert' do
      tags 'Spreads'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string
  
      response '200', 'alert found' do
        let(:id) { 'BTC-CLP' }
        schema type: :object,
          properties: {
            alert_triggered: { type: :boolean },
            current_spread: { type: :number },
            target_spread: { type: :number }
          },
          required: [ 'alert_triggered', 'current_spread', 'target_spread' ]
        run_test!
      end
  
      response '422', 'alert not found' do
        let(:id) { 'INVALID-MARKET' }
        run_test!
      end
    end
  end
  
end