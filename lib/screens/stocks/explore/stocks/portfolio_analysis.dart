import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../provider/stocks_provider.dart';
import '../../../../models/explore_model/portfolioanalisys_models.dart';

class PortfolioDashboardScreen extends ConsumerStatefulWidget {
  const PortfolioDashboardScreen({super.key});

  @override
  ConsumerState<PortfolioDashboardScreen> createState() => _PortfolioDashboardScreenState();
}

class _PortfolioDashboardScreenState extends ConsumerState<PortfolioDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(stocksProvide).getPortfolioAnalysis();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('Portfolio Dashboard', 
          style: TextStyle(
            color: Color(0xFF2E3A59), 
            fontWeight: FontWeight.w600,
            fontSize: 18,
          )),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF2E3A59)),
            onPressed: () {
              ref.read(stocksProvide).getPortfolioAnalysis();
            },
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          if (ref.watch(stocksProvide).isPortfolioLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF059B3C)),
                  SizedBox(height: 16),
                  Text('Loading portfolio data...', 
                    style: TextStyle(color: Color(0xFF6C7B93))),
                ],
              ),
            );
          }

          if (ref.watch(stocksProvide).portfolioError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error loading data', 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text(ref.watch(stocksProvide).portfolioError!, 
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(stocksProvide).getPortfolioAnalysis();
                    },
                    child: Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF059B3C),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          if (!ref.watch(stocksProvide).hasPortfolioData) {
            return Center(
              child: Text('No data available', 
                style: TextStyle(fontSize: 16, color: Color(0xFF6C7B93))),
            );
          }

          return _buildDashboardContent(ref.watch(stocksProvide).portfolioAnalysis!);
        },
      ),
    );
  }

  Widget _buildDashboardContent(PortfolioResponse data) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPortfolioSummary(data),
          SizedBox(height: 16),
          // _buildQuickStatsCards(data),
          // SizedBox(height: 16),
          if (data.chartData != null) _buildInvestmentChart(data.chartData!),
          SizedBox(height: 16),
          _buildAccountAllocation(data.accountAllocation),
          SizedBox(height: 16),
          _buildChartsSection(data),
          SizedBox(height: 16),
          _buildTopStocks(data.topStocks),
          SizedBox(height: 16),
          _buildSectorAllocationTable(data.sectorAllocation),
          SizedBox(height: 16),
          _buildFundamentalsTable(data.fundamentals),
        ],
      ),
    );
  }

  Widget _buildPortfolioSummary(PortfolioResponse data) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portfolio Summary',
            style: TextStyle(
              color: Color(0xFF2E3A59),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Text(
                'XIRR Return: ',
                style: TextStyle(
                  color: Color(0xFF6C7B93), 
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${data.xirrResult.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: Color(0xFF059B3C),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsCards(PortfolioResponse data) {
    double currentValue = 0;
    double investedValue = 0;
    
    if (data.chartData != null && data.chartData!.totalCurrentValue.isNotEmpty) {
      currentValue = data.chartData!.totalCurrentValue.last;
      investedValue = data.chartData!.totalInvestedValue.last;
    }
    
    double pnl = currentValue - investedValue;
    double pnlPercentage = investedValue > 0 ? (pnl / investedValue) * 100 : 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Current Value',
            '₹${_formatAmount(currentValue)}',
            Color(0xFF059B3C),
            Icons.account_balance_wallet,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'P&L',
            '₹${_formatAmount(pnl)}',
            pnl >= 0 ? Color(0xFF059B3C) : Colors.red,
            pnl >= 0 ? Icons.trending_up : Icons.trending_down,
            subtitle: '${pnlPercentage.toStringAsFixed(2)}%',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon, {String? subtitle}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Color(0xFF6C7B93),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInvestmentChart(ChartData chartData) {
    if (chartData.dates.isEmpty) return SizedBox.shrink();

    // Optimize data points for mobile performance
    final maxPoints = 50;
    final step = (chartData.dates.length / maxPoints).ceil().clamp(1, chartData.dates.length);
    
    List<FlSpot> investedSpots = [];
    List<FlSpot> currentSpots = [];
    
    for (int i = 0; i < chartData.dates.length; i += step) {
      investedSpots.add(FlSpot(i.toDouble(), chartData.totalInvestedValue[i] / 1000)); // Convert to thousands
      currentSpots.add(FlSpot(i.toDouble(), chartData.totalCurrentValue[i] / 1000));
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
       
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Investment vs Current Value Over Time',
            style: TextStyle(
              color: Color(0xFF2E3A59),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Color(0xFFE8ECF1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}K',
                          style: TextStyle(
                            color: Color(0xFF6C7B93),
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // Investment Line
                  LineChartBarData(
                    spots: investedSpots,
                    isCurved: true,
                    color: Color(0xFF6C7B93),
                    barWidth: 2,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                  // Current Value Line
                  LineChartBarData(
                    spots: currentSpots,
                    isCurved: true,
                    color: Color(0xFF059B3C),
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Color(0xFF059B3C).withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          // Chart Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChartLegend('Invested', Color(0xFF6C7B93)),
              SizedBox(width: 20),
              _buildChartLegend('Current', Color(0xFF059B3C)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF6C7B93),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountAllocation(Map<String, double> allocation) {
    if (allocation.isEmpty) return SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Allocation',
            style: TextStyle(
              color: Color(0xFF2E3A59),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          ...allocation.entries.map((entry) => 
            _buildAllocationRow(entry.key, entry.value)
          ).toList(),
        ],
      ),
    );
  }

  Widget _buildAllocationRow(String asset, double percentage) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            asset,
            style: TextStyle(
              color: Color(0xFF2E3A59), 
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              color: Color(0xFF059B3C),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(PortfolioResponse data) {
    return Column(
      children: [
        _buildMarketCapChart(data.marketCapAllocation),
        SizedBox(height: 16),
        _buildSectorChart(data.sectorAllocation),
      ],
    );
  }

  Widget _buildMarketCapChart(Map<String, double> allocation) {
    if (allocation.isEmpty) return SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
       
      ),
      child: Column(
        children: [
          Text(
            'Market Cap Allocation',
            style: TextStyle(
              color: Color(0xFF2E3A59),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: allocation.entries.map((entry) {
                  return PieChartSectionData(
                    value: entry.value,
                    title: '${entry.value.toStringAsFixed(1)}%',
                    color: _getMarketCapColor(entry.key),
                    radius: 80,
                    titleStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          SizedBox(height: 16),
          // Market Cap Legend
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            children: allocation.entries.map((entry) => 
              _buildPieChartLegend(entry.key, _getMarketCapColor(entry.key))
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectorChart(Map<String, double> allocation) {
    if (allocation.isEmpty) return SizedBox.shrink();

    final topSectors = ref.read(stocksProvide).getTopSectors(limit: 6);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Sector Allocation (Top 6)',
            style: TextStyle(
              color: Color(0xFF2E3A59),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: topSectors.entries.map((entry) {
                  return PieChartSectionData(
                    value: entry.value,
                    title: '${entry.value.toStringAsFixed(1)}%',
                    color: _getSectorColor(entry.key),
                    radius: 80,
                    titleStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          SizedBox(height: 16),
          // Sector Legend (showing only top ones)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: topSectors.entries.take(6).map((entry) => 
              _buildPieChartLegend(
                entry.key.length > 12 ? '${entry.key.substring(0, 12)}...' : entry.key,
                _getSectorColor(entry.key)
              )
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF6C7B93),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTopStocks(List<TopStock> stocks) {
    if (stocks.isEmpty) return SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Top Holdings (${stocks.length})',
              style: TextStyle(
                color: Color(0xFF2E3A59),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...stocks.take(10).map((stock) => _buildStockItem(stock)).toList(),
          if (stocks.length > 10)
            Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'View All ${stocks.length} Holdings',
                  style: TextStyle(
                    color: Color(0xFF059B3C),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStockItem(TopStock stock) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE8ECF1), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFF059B3C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                stock.tsym.length >= 2 ? stock.tsym.substring(0, 2) : stock.tsym,
                style: TextStyle(
                  color: Color(0xFF059B3C),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stock.name,
                  style: TextStyle(
                    color: Color(0xFF2E3A59),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Text(
                  stock.tsym,
                  style: TextStyle(
                    color: Color(0xFF6C7B93),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${stock.allocationPercent.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: Color(0xFF059B3C),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getMarketCapColor(stock.marketCapType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  stock.marketCapType,
                  style: TextStyle(
                    color: _getMarketCapColor(stock.marketCapType),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectorAllocationTable(Map<String, double> allocation) {
    if (allocation.isEmpty) return SizedBox.shrink();

    final sortedEntries = allocation.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sector Allocation - Full List (${sortedEntries.length} sectors)',
            style: TextStyle(
              color: Color(0xFF2E3A59),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          ...sortedEntries.map((entry) => 
            _buildTableRow(entry.key, '${entry.value.toStringAsFixed(1)}%')
          ).toList(),
        ],
      ),
    );
  }

  Widget _buildFundamentalsTable(List<Fundamental> fundamentals) {
    if (fundamentals.isEmpty) return SizedBox.shrink();

    final sortedFundamentals = fundamentals.where((f) => f.value != null).toList()
      ..sort((a, b) => (b.value ?? 0).compareTo(a.value ?? 0));

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Fundamentals (${sortedFundamentals.length} holdings)',
              style: TextStyle(
                color: Color(0xFF2E3A59),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: DataTable(
              columnSpacing: 16,
              headingRowColor: MaterialStateProperty.all(Color(0xFFF8F9FA)),
              columns: [
                DataColumn(
                  label: Text('Company', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                DataColumn(
                  label: Text('Symbol', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                DataColumn(
                  label: Text('Sector', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                DataColumn(
                  label: Text('Qty', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                DataColumn(
                  label: Text('Price (₹)', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                DataColumn(
                  label: Text('Value (₹)', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                DataColumn(
                  label: Text('Cap Type', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
              rows: sortedFundamentals.take(15).map((fund) => 
                DataRow(
                  cells: [
                    DataCell(
                      Container(
                        width: 100,
                        child: Text(
                          fund.companyName ?? 'N/A',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(fund.tsym ?? 'N/A', 
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                    DataCell(
                      Container(
                        width: 80,
                        child: Text(
                          fund.sector ?? 'N/A',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    DataCell(
                      Text('${fund.qty ?? 0}', 
                        style: TextStyle(fontSize: 11)),
                    ),
                    DataCell(
                      Text('${(fund.uploadedPrice ?? 0).toStringAsFixed(2)}', 
                        style: TextStyle(fontSize: 11)),
                    ),
                    DataCell(
                      Text(
                        '${_formatAmount(fund.value ?? 0)}',
                        style: TextStyle(
                          color: Color(0xFF059B3C),
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getMarketCapColor(fund.marketCapType ?? '').withOpacity(0.1),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          fund.marketCapType ?? 'N/A',
                          style: TextStyle(
                            color: _getMarketCapColor(fund.marketCapType ?? ''),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ).toList(),
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTableRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Color(0xFF2E3A59),
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Color(0xFF059B3C),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(2)}Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(2)}K';
    } else {
      return amount.toStringAsFixed(2);
    }
  }

  Color _getMarketCapColor(String capType) {
    switch (capType.toLowerCase()) {
      case 'large cap': return Color(0xFF059B3C);
      case 'mid cap': return Color(0xFF1976D2);  
      case 'small cap': return Color(0xFFFF7043);
      default: return Color(0xFF6C7B93);
    }
  }

  Color _getSectorColor(String sector) {
    List<Color> colors = [
      Color(0xFF059B3C), Color(0xFF1976D2), Color(0xFFFF7043),
      Color(0xFF7B1FA2), Color(0xFF388E3C), Color(0xFFE64A19),
      Color(0xFF0288D1), Color(0xFF8E24AA), Color(0xFF43A047),
      Color(0xFFFFA726), Color(0xFF5C6BC0), Color(0xFF26A69A),
    ];
    return colors[sector.hashCode % colors.length];
  }
}
