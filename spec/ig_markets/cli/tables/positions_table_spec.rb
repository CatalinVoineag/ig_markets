describe IGMarkets::CLI::Tables::PositionsTable do
  it 'prints positions' do
    positions = [build(:position), build(:position, level: 100.1, contract_size: 100)]

    expect(described_class.new(positions).to_s).to eql(<<-END.strip
+-------------------------+--------------------+------------+-----------+------+-------+---------+-------+------+-------+------+-------------+----------+
|                                                                       Positions                                                                       |
+-------------------------+--------------------+------------+-----------+------+-------+---------+-------+------+-------+------+-------------+----------+
| Date                    | EPIC               | Type       | Direction | Size | Level | Current | High  | Low  | Limit | Stop | Profit/loss | Deal IDs |
+-------------------------+--------------------+------------+-----------+------+-------+---------+-------+------+-------+------+-------------+----------+
| 2015-07-24 09:12:37 UTC | CS.D.EURUSD.CFD.IP | Currencies | Buy       | 10.4 | 100.0 |   100.0 | 110.0 | 90.0 | 110.0 | 90.0 |    #{ColorizedString['USD 0.00'].green} | DEAL     |
| 2015-07-24 09:12:37 UTC | CS.D.EURUSD.CFD.IP | Currencies | Buy       | 10.4 | 100.1 |   100.0 | 110.0 | 90.0 | 110.0 | 90.0 | #{ColorizedString['USD -104.00'].red} | DEAL     |
+-------------------------+--------------------+------------+-----------+------+-------+---------+-------+------+-------+------+-------------+----------+
END
                                                      )
  end

  it 'prints positions in aggregate' do
    positions = [build(:position, level: 100.0, size: 0.1), build(:position, level: 130.0, size: 0.2)]

    expect(described_class.new(positions, aggregate: true).to_s).to eql(<<-END.strip
+------+--------------------+------------+-----------+------+-------+---------+-------+------+-------+------+--------------+------------+
|                                                               Positions                                                               |
+------+--------------------+------------+-----------+------+-------+---------+-------+------+-------+------+--------------+------------+
| Date | EPIC               | Type       | Direction | Size | Level | Current | High  | Low  | Limit | Stop | Profit/loss  | Deal IDs   |
+------+--------------------+------------+-----------+------+-------+---------+-------+------+-------+------+--------------+------------+
|      | CS.D.EURUSD.CFD.IP | Currencies | Buy       |  0.3 | 120.0 |   100.0 | 110.0 | 90.0 |       |      | #{ColorizedString['USD -6000.00'].red} | DEAL, DEAL |
+------+--------------------+------------+-----------+------+-------+---------+-------+------+-------+------+--------------+------------+
END
                                                                       )
  end
end
