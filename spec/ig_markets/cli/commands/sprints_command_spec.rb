describe IGMarkets::CLI::Sprints do
  let(:dealing_platform) { IGMarkets::DealingPlatform.new }

  def cli(arguments = {})
    IGMarkets::CLI::Sprints.new [], arguments
  end

  before do
    expect(IGMarkets::CLI::Main).to receive(:begin_session).and_yield(dealing_platform)
  end

  it 'prints sprint market positions' do
    sprint_market_positions = [build(:sprint_market_position), build(:sprint_market_position, strike_level: 99)]
    markets = [build(:market, instrument: build(:instrument, epic: 'FM.D.FTSE.FTSE.IP'))]

    expect(sprint_market_positions[0]).to receive(:seconds_till_expiry).and_return(125)
    expect(sprint_market_positions[1]).to receive(:seconds_till_expiry).and_return(125)
    expect(dealing_platform.sprint_market_positions).to receive(:all).and_return(sprint_market_positions)
    expect(dealing_platform.markets).to receive(:find).with(['FM.D.FTSE.FTSE.IP']).and_return(markets)

    expect { cli.list }.to output(<<-END
+-------------------+-----------+------------+--------------+---------+-------------------+------------+---------+
|                                            Sprint market positions                                             |
+-------------------+-----------+------------+--------------+---------+-------------------+------------+---------+
| EPIC              | Direction | Size       | Strike level | Current | Expires in (m:ss) | Payout     | Deal ID |
+-------------------+-----------+------------+--------------+---------+-------------------+------------+---------+
| FM.D.FTSE.FTSE.IP | Buy       | USD 120.50 |        110.1 |    99.5 |              2:05 | #{'USD 210.80'.red} | DEAL    |
| FM.D.FTSE.FTSE.IP | Buy       | USD 120.50 |         99.0 |    99.5 |              2:05 | #{'USD 210.80'.green} | DEAL    |
+-------------------+-----------+------------+--------------+---------+-------------------+------------+---------+
END
                                 ).to_stdout
  end

  it 'creates a sprint market position' do
    arguments = { direction: 'buy', epic: 'CS.D.EURUSD.CFD.IP', expiry_period: '5', size: '10' }

    expect(dealing_platform.sprint_market_positions).to receive(:create).with(
      direction: 'buy', epic: 'CS.D.EURUSD.CFD.IP', expiry_period: :five_minutes, size: '10').and_return('ref')

    expect(IGMarkets::CLI::Main).to receive(:report_deal_confirmation).with('ref')

    cli(arguments).create
  end
end
