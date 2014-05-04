require "spec_helper"

describe Lita::Handlers::Google, lita_handler: true do
  it { routes_command("google ruby").to(:search) }
  it { routes_command("google me ruby").to(:search) }
  it { routes_command("g ruby").to(:search) }

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
  end
end
