module Artemis
  module Adapters
    # We overwrite execute so we can sign the request with HMAC
    class NetHttpHmacAdapter < Artemis::Adapters::NetHttpAdapter
      # Makes an HTTP request for GraphQL query.
      def execute(document:, operation_name: nil, variables: {}, context: {})
        request = Net::HTTP::Post.new(uri.request_uri)
        request.basic_auth(uri.user, uri.password) if uri.user || uri.password

        request['Accept'] = 'application/json'
        request['Content-Type'] = 'application/json'
        headers(context).each { |name, value| request[name] = value }

        body = {}
        body['query'] = document.to_query_string
        body['variables'] = variables if variables.any?
        body['operationName'] = operation_name if operation_name
        request.body = JSON.generate(body)

        # Only changes are in here
        signed_request = api_auth_sign_request!(request, context.fetch(:api_auth))
        response = connection.request(signed_request)

        case response.code.to_i
        when 200, 400
          JSON.parse(response.body)
        when 500..599
          raise Artemis::GraphQLServerError, "Received server error status #{response.code}: #{response.body}"
        else
          { 'errors' => [{ 'message' => "#{response.code} #{response.message}" }] }
        end
      end

      private

      def api_auth_sign_request!(request, api_auth)
        override_http_method = api_auth.fetch(:override_http_method, nil)
        digest = api_auth.fetch(:digest, 'sha256')
        ::ApiAuth.sign!(
          request,
          api_auth.fetch(:access_id), api_auth.fetch(:secret_key),
          override_http_method: override_http_method, digest: digest)
      end
    end
  end
end
