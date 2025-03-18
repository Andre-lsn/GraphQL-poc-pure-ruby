# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

# GraphQL Client Configuration
class GraphQLClient
  def initialize(endpoint)
    @uri = URI(endpoint)
  end

  def execute(query, variables = {})
    response = http_request(query, variables)
    parse_response(response)
  end

  private

  attr_reader :uri

  def http_request(query, variables)
    Net::HTTP.start(uri.host, uri.port, use_ssl: ssl?) do |http|
      request = Net::HTTP::Post.new(uri, { 'Content-Type' => 'application/json' })
      request.body = { query:, variables: }.to_json
      http.request(request)
    end
  end

  def parse_response(response)
    JSON.parse(response.body)
  rescue JSON::ParserError
    { error: 'Invalid JSON response' }
  end

  def ssl?
    uri.scheme == 'https'
  end
end
