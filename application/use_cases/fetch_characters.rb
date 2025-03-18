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
        response = client.execute(query, { name:, page:, status: })
        data = response['data']['characters']
        {
          characters: data['results'],
          total: data['info']['count']
        }
      end

      private

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
