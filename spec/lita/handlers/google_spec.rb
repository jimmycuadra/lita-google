require "spec_helper"

describe Lita::Handlers::Google, lita_handler: true do
  it { routes_command("google ruby").to(:search) }
  it { routes_command("google me ruby").to(:search) }

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
      "url": "https://www.ruby-lang.org/",
      "titleNoFormatting": "Ruby Programming Language"
    }]
  }
}
JSON
      )

      send_command("google ruby")

      expect(replies.last).to eq(
        "Ruby Programming Language - https://www.ruby-lang.org/"
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
