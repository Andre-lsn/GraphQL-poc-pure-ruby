# frozen_string_literal: true

module Application
  module UseCases
    # Fetch Chracters Use Case
    class FetchCharacters
      def initialize(name:, status:, pagination_params:, client:)
        @name = name
        @status = status
        @page = pagination_params[:page] || 1
        @per_page = pagination_params[:per_page] || 5
        @client = client
      end

      def call
        validate_input!

        response = fetch_characters
        data = response['data']['characters']
        {
          characters: data['results'],
          total: data['info']['count']
        }
      end

      private

      def validate_input!
        raise ArgumentError, 'Character name cannot be nil or empty' if name.strip.empty?
        raise ArgumentError, 'Page number must be positive' if page.to_i <= 0
      end

      def fetch_characters
        client.execute(query, { name:, page:, status: })
      rescue Faraday::ConnectionFailed => e
        raise "Network error: #{e.message}"
      rescue StandardError => e
        raise "Unexpected API error: #{e.message}"
      end

      def query
        <<~GRAPHQL
          query($name: String!, $status: String, $page: Int) {
            characters(page: $page, filter: { name: $name, status: $status }) {
              info {
                count
              }
              results {
                name
                species
                image
                origin {
                  name
                }
                location {
                  name
                  type
                  dimension
                }
              }
            }
          }
        GRAPHQL
      end

      attr_reader :client, :name, :status, :page
    end
  end
end
