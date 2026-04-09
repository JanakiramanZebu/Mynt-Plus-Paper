/// Data point for a single timestamp in the group P&L chart.
class GroupPnlDataPoint {
  final DateTime time;
  final double pnl;
  final double drawdown;
  final double peak;

  const GroupPnlDataPoint({
    required this.time,
    required this.pnl,
    required this.drawdown,
    required this.peak,
  });
}
