require "spec_helper"

describe Lita::Handlers::Google, lita_handler: true do
  it { is_expected.to route_command("google ruby").to(:search) }
  it { is_expected.to route_command("google me ruby").to(:search) }
  it { is_expected.to route_command("g ruby").to(:search) }

  describe "#search" do
    let(:response) do
      response = double("Faraday::Response")
      allow(response).to receive(:status).and_return(200)
      response
    end

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(
        response
      )
    end

    it "replies with the first title and URL for the query" do
      allow(response).to receive(:body).and_return(
<<-JSON.chomp
{
  "responseData": {
    "results": [{
      "unescapedUrl": "http://www.youtube.com/watch?v=EwTZ2xpQwpA",
      "titleNoFormatting": "&quot;Chocolate Rain&quot; Original Song by Tay Zonday"
    }]
  }
}
JSON
      )

      send_command("google ruby")

      expect(replies.last).to eq(
        %{"Chocolate Rain" Original Song by Tay Zonday - http://www.youtube.com/watch?v=EwTZ2xpQwpA}
      )
    end

    it "replies that no results were found if the results are empty" do
      allow(response).to receive(:body).and_return(
<<-JSON.chomp
{
  "responseData": {
    "results": []
  }
}
JSON
      )

      send_command("google ruby")

      expect(replies.last).to match(/No search results/)
    end

    it "logs a warning on non-200 response" do
      allow(response).to receive(:status).and_return(500)

      expect(Lita.logger).to receive(:warn).with(/Non-200 response from Google/)

      send_command("google ruby")
    end

    it "skips over domains that are blacklisted config" do
      registry.config.handlers.google.excluded_domains = ['funnyjunk.com' ,'gawker.com']

      allow(response).to receive(:body).and_return(
<<-JSON.chomp
{
  "responseData": {
    "results": [
      {
        "unescapedUrl": "http://www.funnyjunk.com",
        "titleNoFormatting": "Funny pictures blah blah"
      },
      {
        "unescapedUrl": "http://theoatmeal.com/blog/funnyjunk2",
        "titleNoFormatting": "An update on the FunnyJunk situation"
      }
  ]
  }
}
JSON
      )

      send_command("google funnyjunk")

      expect(replies.last).to eq(
        "An update on the FunnyJunk situation - http://theoatmeal.com/blog/funnyjunk2"
      )
    end
    it "fails gracefully if URI.parse raises an error" do
      registry.config.handlers.google.excluded_domains = ['dailmail.co.uk']

      allow(response).to receive(:body).and_return(
<<-JSON.chomp
{
  "responseData": {
    "results": [
      {
        "unescapedUrl": "555-867-5309",
        "titleNoFormatting": "Funny pictures blah blah"
      }
  ]
  }
}
JSON
      )

      send_command("google funnyjunk")

      expect(replies.last).to eq(
        "Funny pictures blah blah - 555-867-5309"
      )
    end

  end
end
