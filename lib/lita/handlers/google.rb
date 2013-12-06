require "lita"

module Lita
  module Handlers
    class Google < Handler
      URL = "https://ajax.googleapis.com/ajax/services/search/web"

      route(/^google\s+(.+)/i, :search, command: true, help: {
        "google QUERY" => "Return the first Google search result for QUERY."
      })

      def self.default_config(handler_config)
        handler_config.safe_search = :active
      end

      def search(response)
        query = response.matches[0][0]

        http_response = http.get(
          URL,
          safe: safe_value,
          q: query,
          v: "1.0"
        )

        if http_response.status == 200
          data = MultiJson.load(http_response.body)
          result = data["responseData"]["results"].first

          if result
            response.reply("#{result["titleNoFormatting"]} - #{result["url"]}")
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

      def safe_value
        safe = Lita.config.handlers.google.safe_search || "active"
        safe = safe.to_s.downcase
        safe = "active" unless ["active", "moderate", "off"].include?(safe)
        safe
      end
    end

    Lita.register_handler(Google)
  end
end
