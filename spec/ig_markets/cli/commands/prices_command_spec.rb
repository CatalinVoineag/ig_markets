describe IGMarkets::CLI::Main do
  let(:dealing_platform) { IGMarkets::DealingPlatform.new }

  def cli(arguments = {})
    IGMarkets::CLI::Main.new [], { username: '', password: '', api_key: '' }.merge(arguments)
  end

  let(:market) do
    attributes = {
      dealing_rules: build(:market_dealing_rules),
      instrument: build(:instrument),
      snapshot: build(:market_snapshot)
    }

    dealing_platform.instantiate_models IGMarkets::Market, attributes
  end

  before do
    expect(IGMarkets::CLI::Main).to receive(:begin_session).and_yield(dealing_platform)
    expect(dealing_platform.markets).to receive(:[]).with('A').and_return(market)
  end

  it 'reports an error on invalid arguments' do
    expect { cli(epic: 'A').prices }.to raise_error(ArgumentError)
  end

  it 'lists recent prices' do
    historical_price_result = build :historical_price_result

    expect(market).to receive(:historical_prices).with(resolution: :day, max: 1).and_return(historical_price_result)

    expect { cli(epic: 'A', resolution: :day, number: 1).prices }.to output(<<-END
+-------------------------+------+-------+-----+------+
|                    Prices for A                     |
+-------------------------+------+-------+-----+------+
| Date                    | Open | Close | Low | High |
+-------------------------+------+-------+-----+------+
| 2015-06-16 00:00:00 UTC |  100 |   100 | 100 |  100 |
+-------------------------+------+-------+-----+------+

Allowance: 5000
Remaining: 4990
END
                                                                           ).to_stdout
  end

  it 'lists prices in a date range' do
    historical_price_result = build :historical_price_result

    options = {
      resolution: :day,
      from: Time.new(2014, 1, 2, 3, 4, 0, '+00:00'),
      to: Time.new(2014, 2, 3, 4, 5, 0, '+00:00')
    }

    expect(market).to receive(:historical_prices).with(options).and_return(historical_price_result)

    expect do
      cli(epic: 'A', resolution: :day, start_date: '2014-01-02T03:04+00:00', end_date: '2014-02-03T04:05+00:00').prices
    end.to output(<<-END
+-------------------------+------+-------+-----+------+
|                    Prices for A                     |
+-------------------------+------+-------+-----+------+
| Date                    | Open | Close | Low | High |
+-------------------------+------+-------+-----+------+
| 2015-06-16 00:00:00 UTC |  100 |   100 | 100 |  100 |
+-------------------------+------+-------+-----+------+

Allowance: 5000
Remaining: 4990
END
                 ).to_stdout
  end
end
