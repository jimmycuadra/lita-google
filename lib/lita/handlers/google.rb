require "cgi"
require "uri"

require "lita"

module Lita
  module Handlers
    class Google < Handler
      URL = "https://ajax.googleapis.com/ajax/services/search/web"
      VALID_SAFE_VALUES = %w(active moderate off)

      config :safe_search, types: [String, Symbol], default: :active do
        validate do |value|
          unless VALID_SAFE_VALUES.include?(value.to_s.strip)
            "valid values are :active, :moderate, or :off"
          end
        end
      end

      config :excluded_domains, type: Array

      route(/^(?:google|g)\s+(.+)/i, :search, command: true, help: {
        "google QUERY" => "Return the first Google search result for QUERY."
      })

      def search(response)
        query = response.matches[0][0]
        result = nil

        http_response = http.get(
          URL,
          safe: config.safe_search,
          q: query,
          v: "1.0"
        )

        if http_response.status == 200
          data = MultiJson.load(http_response.body)

          if config.excluded_domains
            result = check_for_excluded_domains(data)
          else
            result = data["responseData"]["results"].first
          end

          if result
            response.reply(
              "#{CGI.unescapeHTML(result["titleNoFormatting"])} - #{result["unescapedUrl"]}"
            )
          else
            response.reply("No search results for query: #{query}")
          end
        else
          Lita.logger.warn(
            "Non-200 response from Google for search query: #{query}"
          )
        end
      end
      private

      def check_for_excluded_domains(data)
        data["responseData"]["results"].find do |response|
          begin
            uri = URI.parse(response["unescapedUrl"])
            if uri && uri.host
              response if config.excluded_domains.none? { |domain| uri.host.include?(domain) }
            else
              response
            end
          rescue URI::InvalidURIError
            nil
          end
        end
      end
    end

    Lita.register_handler(Google)
  end
end
