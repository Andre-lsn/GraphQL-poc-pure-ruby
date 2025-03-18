# frozen_string_literal: true

require 'sinatra'

require './infrastructure/client'
require './application/use_cases/fetch_characters'

get '/api/v1/characters' do
  result = Application::UseCases::FetchCharacters.new(
    name: params['name'],
    status: params['status'],
    pagination_params: {
      page: params['page'].to_i || 1
    },
    client: GraphQLClient.new('https://rickandmortyapi.com/graphql')
  ).call

  { data: result }.to_json
end
