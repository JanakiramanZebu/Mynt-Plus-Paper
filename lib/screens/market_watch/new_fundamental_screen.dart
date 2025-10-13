import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mynt_plus/screens/market_watch/over_view/financial_new.dart';
import 'dart:math' as math;
import '../../models/marketwatch_model/get_quotes.dart';
import '../../models/marketwatch_model/scrip_overview/eodchartdata_model.dart';
import '../../models/marketwatch_model/scrip_overview/stock_data.dart';
import '../../provider/thems.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/websocket_provider.dart';
import '../../res/res.dart';
import '../../res/global_state_text.dart';
import '../../sharedWidget/no_data_found.dart';
import 'over_view/price_comparision.dart';

class PriceData {
  final DateTime date;
  final double price;
  final int volume;

  PriceData({
    required this.date,
    required this.price,
    required this.volume,
  });
}

class EventData {
  final DateTime date;
  final String type;
  final String title;
  final String description;

  EventData({
    required this.date,
    required this.type,
    required this.title,
    required this.description,
  });
}

// Custom Donut Chart Painter for Shareholders Chart
class ShareholdersDonutChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final ThemesProvider theme;

  ShareholdersDonutChartPainter({
    required this.data,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 20.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Calculate total value for percentage calculation
    final total =
        data.fold(0.0, (sum, item) => sum + (item['value'] as double));

    if (total == 0) return;

    double startAngle = -math.pi / 2; // Start from top

    for (final item in data) {
      final value = item['value'] as double;
      final percentage = (value / total * 100);
      final sweepAngle = (value / total) * 2 * math.pi;

      paint.color = item['color'] as Color;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      // Draw percentage text on each segment
      if (percentage > 2.0) {
        // Only show percentage if segment is large enough
        final segmentCenterAngle = startAngle + sweepAngle / 2;
        final textRadius = radius +
            18; // Position text outside the arc with appropriate spacing for 180x180 size
        final textX = center.dx + textRadius * math.cos(segmentCenterAngle);
        final textY = center.dy + textRadius * math.sin(segmentCenterAngle);

        final textPainter = TextPainter(
          text: TextSpan(
            text: '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        final textOffset = Offset(
          textX - textPainter.width / 2,
          textY - textPainter.height / 2,
        );
        textPainter.paint(canvas, textOffset);
      }

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class NewFundamentalScreen extends ConsumerStatefulWidget {
  final DepthInputArgs wlValue;
  final GetQuotes depthData;

  const NewFundamentalScreen({
    super.key,
    required this.wlValue,
    required this.depthData,
  });

  @override
  ConsumerState<NewFundamentalScreen> createState() =>
      _NewFundamentalScreenState();
}

class _NewFundamentalScreenState extends ConsumerState<NewFundamentalScreen> {
  List<PriceData> priceData = [];
  List<EventData> eventData = [];
  bool _hasScrolled = false;
  bool _isLoadingNewData = true; // Initialize as true to prevent "No Data" flash

  // Chart tooltip state (like benchmark_backtest.dart)
  FlSpot? touchedSpot;
  Timer? _hideTooltipTimer;

  // Event colors for each type
  static const Map<String, Color> eventColors = {
    'Announcement': Color(0xFF2196F3), // Blue
    'Bonus': Color(0xFF4CAF50), // Green
    'Dividend': Color(0xFF9C27B0), // Purple
    'Rights': Color(0xFFFF9800), // Orange
    'Split': Color(0xFFF44336), // Red
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Clear any existing data to prevent showing old data
      ref.read(marketWatchProvider).clearChartData();
      ref.read(marketWatchProvider).clearFundamentalData();
      
      // Clear cache for this specific token to ensure fresh data
      if (widget.wlValue.token.isNotEmpty) {
        ref.read(marketWatchProvider).clearCacheForToken(widget.wlValue.token);
      }
      
      ref.read(websocketProvider).socketDataStream.listen((socketData) {
        if (mounted && socketData.containsKey(widget.wlValue.token)) {
          final newData = socketData[widget.wlValue.token];
          if (newData != null) {
            // Only update if values actually changed
            bool valueChanged = false;
            
            final newLtp = newData['lp']?.toString();
            final newChange = newData['chng']?.toString();
            final newPerChange = newData['pc']?.toString();
            
            if (newLtp != null && newLtp != widget.depthData.lp && newLtp != '0.00') {
              widget.depthData.lp = newLtp;
              valueChanged = true;
            }
            
            if (newChange != null && newChange != widget.depthData.chng) {
              widget.depthData.chng = newChange;
              valueChanged = true;
            }
            
            if (newPerChange != null && newPerChange != widget.depthData.pc) {
              widget.depthData.pc = newPerChange;
              valueChanged = true;
            }
            
            // Only rebuild if values actually changed
            if (valueChanged) {
              setState(() {});
            }
          }
        }
      });
      
      // Fetch data in parallel for better performance
      if (widget.wlValue.exch == "NSE" || widget.wlValue.exch == "BSE") {
        final tradeSym = "${widget.wlValue.exch}:${widget.wlValue.tsym}";
        
        // Load both data sources in parallel
        Future.wait([
          ref.read(marketWatchProvider).fetchFundamentalData(
            tradeSym: tradeSym,
            token: widget.wlValue.token,
          ),
          ref.read(marketWatchProvider).fetchEODChartData(
            widget.wlValue.symbol,
            widget.wlValue.exch,
            timeframe: "5Y",
          ),
        ]).then((_) {
          // Fetch technical data for returns calculation after other data is loaded
          ref.read(marketWatchProvider).fetchTechData(
            exch: widget.wlValue.exch,
            tradeSym: widget.wlValue.tsym,
            lastPrc: "${widget.depthData.lp ?? widget.depthData.c ?? 0.00}",
            context: context,
          ).then((_) {
            // Calculate returns using the same logic as scrip_depth_info.dart
            ref.read(marketWatchProvider).techDataCalc("${widget.depthData.lp ?? widget.depthData.c ?? 0.00}");
          });
          if (mounted) {
            setState(() {
              _isLoadingNewData = false;
            });
          }
        }).catchError((error) {
          debugPrint("Error loading data: $error");
          if (mounted) {
            setState(() {
              _isLoadingNewData = false;
            });
          }
        });
      } else {
        setState(() {
          _isLoadingNewData = false;
        });
      }
      
    });
  }

  @override
  void dispose() {
    _hideTooltipTimer?.cancel();
    super.dispose();
  }

  // Process WebSocket data for live updates (same as scrip_depth_info.dart)
  void _processDepthData(GetQuotes depthData, Map<String, dynamic> socketData) {
    depthData.ap = "${socketData['ap']}";
    depthData.lp = "${socketData['lp']}";
    depthData.pc = "${socketData['pc']}";
    depthData.o = "${socketData['o']}";
    depthData.l = "${socketData['l']}";
    depthData.c = "${socketData['c']}";
    depthData.chng = "${socketData['chng']}";
    depthData.h = "${socketData['h']}";
    depthData.poi = "${socketData['poi']}";
    depthData.v = "${socketData['v']}";
    depthData.toi = "${socketData['toi']}";
    depthData.sp1 = "${socketData['sp1']}";
    depthData.sp2 = "${socketData['sp2']}";
    depthData.sp3 = "${socketData['sp3']}";
    depthData.sp4 = "${socketData['sp4']}";
    depthData.sp5 = "${socketData['sp5']}";
    depthData.bp1 = "${socketData['bp1']}";
    depthData.bp2 = "${socketData['bp2']}";
    depthData.bp3 = "${socketData['bp3']}";
    depthData.bp4 = "${socketData['bp4']}";
    depthData.bp5 = "${socketData['bp5']}";
    depthData.sq1 = "${socketData['sq1']}";
    depthData.sq2 = "${socketData['sq2']}";
    depthData.sq3 = "${socketData['sq3']}";
    depthData.sq4 = "${socketData['sq4']}";
    depthData.sq5 = "${socketData['sq5']}";
    depthData.bq1 = "${socketData['bq1']}";
    depthData.bq2 = "${socketData['bq2']}";
    depthData.bq3 = "${socketData['bq3']}";
    depthData.bq4 = "${socketData['bq4']}";
    depthData.bq5 = "${socketData['bq5']}";
    depthData.tbq = "${socketData['tbq']}";
    depthData.tsq = "${socketData['tsq']}";
    depthData.wk52H = "${socketData['52h']}";
    depthData.wk52L = "${socketData['52l']}";
    depthData.lc = "${socketData['lc']}";
    depthData.uc = "${socketData['uc']}";
    depthData.ltq = "${socketData['ltq']}";
    depthData.ltt = "${socketData['ltt']}";
    depthData.ft = "${socketData['ft']}";
  }

  void _convertApiDataToPriceData(
      List<EodChartData> eodDataList, String selectedTimeframe) {
    print(
        "Converting API data: ${eodDataList.length} items for timeframe: $selectedTimeframe");

    if (eodDataList.isEmpty) {
      print("EOD data list is empty");
      priceData = [];
      return;
    }

    // Convert all data first (5Y data fetched by default)
    final allPriceData = eodDataList.map((eodData) {
      // Use time as date and intc as close price
      final time = eodData.time;
      final close = eodData.intc;
      final volume = eodData.intv;

      // Parse date from time string
      DateTime date;
      if (time.isNotEmpty) {
        try {
          // Handle date format like "26-SEP-2025"
          final parts = time.split('-');
          if (parts.length == 3) {
            final day = int.parse(parts[0]);
            final month = _getMonthNumber(parts[1]);
            final year = int.parse(parts[2]);
            date = DateTime(year, month, day);
          } else {
            date = DateTime.parse(time);
          }
        } catch (e) {
          print("Error parsing date: $time, error: $e");
          date = DateTime.now();
        }
      } else {
        date = DateTime.now();
      }

      return PriceData(
        date: date,
        price: close, // intc is close price
        volume: volume.toInt(),
      );
    }).toList();

    // Sort by date to ensure proper chronological order
    allPriceData.sort((a, b) => a.date.compareTo(b.date));

    // Filter based on selected timeframe - use last N data points approach for consistency
    int dataPointsToShow;

    switch (selectedTimeframe) {
      case "1Y":
        // Approximate 250 trading days in a year
        dataPointsToShow = 250;
        break;
      case "3M":
        // Approximate 65 trading days in 3 months
        dataPointsToShow = 65;
        break;
      case "1M":
        // Approximate 22 trading days in 1 month
        dataPointsToShow = 22;
        break;
      case "1W":
        // 7 trading days in 1 week
        dataPointsToShow = 7;
        break;
      default:
        dataPointsToShow = 7;
    }

    // Show the last N data points
    if (allPriceData.length <= dataPointsToShow) {
      priceData = allPriceData;
    } else {
      priceData = allPriceData.sublist(allPriceData.length - dataPointsToShow);
    }

    print(
        "Converted ${priceData.length} price data points for $selectedTimeframe timeframe");
  }

  int _getMonthNumber(String month) {
    const months = {
      'JAN': 1,
      'FEB': 2,
      'MAR': 3,
      'APR': 4,
      'MAY': 5,
      'JUN': 6,
      'JUL': 7,
      'AUG': 8,
      'SEP': 9,
      'OCT': 10,
      'NOV': 11,
      'DEC': 12
    };
    return months[month.toUpperCase()] ?? 1;
  }

  // Convert market watch provider event data to EventData format
  void _convertMarketWatchEventData(MarketWatchProvider marketWatch) {
    if (marketWatch.fundamentalData?.stockEvents == null) return;

    List<EventData> convertedEvents = [];

    // Convert announcements
    if (marketWatch.fundamentalData!.stockEvents!.announcement != null) {
      for (var announcement
          in marketWatch.fundamentalData!.stockEvents!.announcement!) {
        if (announcement.boardMeetingDate != null) {
          try {
            final date = DateTime.parse(announcement.boardMeetingDate!);
            convertedEvents.add(EventData(
              date: date,
              type: 'Announcement',
              title: 'Board Meeting',
              description: announcement.agenda ?? 'Board meeting scheduled',
            ));
          } catch (e) {
            print(
                'Error parsing announcement date: ${announcement.boardMeetingDate}');
          }
        }
      }
    }

    // Convert dividends
    if (marketWatch.fundamentalData!.stockEvents!.dividend != null) {
      for (var dividend
          in marketWatch.fundamentalData!.stockEvents!.dividend!) {
        if (dividend.dividendDate != null) {
          try {
            final date = DateTime.parse(dividend.dividendDate!);
            convertedEvents.add(EventData(
              date: date,
              type: 'Dividend',
              title: 'Dividend',
              description:
                  '${dividend.dividendPercent ?? 'N/A'}% - ${dividend.dividendpershare ?? 'N/A'} per share',
            ));
          } catch (e) {
            print('Error parsing dividend date: ${dividend.dividendDate}');
          }
        }
      }
    }

    // Convert bonus
    if (marketWatch.fundamentalData!.stockEvents!.bonus != null) {
      for (var bonus in marketWatch.fundamentalData!.stockEvents!.bonus!) {
        if (bonus.recordDate != null) {
          try {
            final date = DateTime.parse(bonus.recordDate!);
            convertedEvents.add(EventData(
              date: date,
              type: 'Bonus',
              title: 'Bonus Issue',
              description:
                  '${bonus.ratioD ?? 'N/A'}:${bonus.ratioN ?? 'N/A'} bonus ratio',
            ));
          } catch (e) {
            print('Error parsing bonus date: ${bonus.recordDate}');
          }
        }
      }
    }

    // Convert rights
    if (marketWatch.fundamentalData!.stockEvents!.rights != null) {
      for (var rights in marketWatch.fundamentalData!.stockEvents!.rights!) {
        if (rights.exRightsDate != null) {
          try {
            final date = DateTime.parse(rights.exRightsDate!);
            convertedEvents.add(EventData(
              date: date,
              type: 'Rights',
              title: 'Rights Issue',
              description: 'Price: ₹${rights.offerPrice ?? 'N/A'}',
            ));
          } catch (e) {
            print('Error parsing rights date: ${rights.exRightsDate}');
          }
        }
      }
    }

    // Convert splits
    if (marketWatch.fundamentalData!.stockEvents!.split != null) {
      for (var split in marketWatch.fundamentalData!.stockEvents!.split!) {
        if (split.exDate != null) {
          try {
            final date = DateTime.parse(split.exDate!);
            convertedEvents.add(EventData(
              date: date,
              type: 'Split',
              title: 'Stock Split',
              description:
                  '${split.fvChangeFrom ?? 'N/A'} to ${split.fvChangeTo ?? 'N/A'}',
            ));
          } catch (e) {
            print('Error parsing split date: ${split.exDate}');
          }
        }
      }
    }

    // Sort events by date
    convertedEvents.sort((a, b) => a.date.compareTo(b.date));
    eventData = convertedEvents;
  }

  // Find the index of a date in priceData
  int _findEventDateIndex(List<PriceData> priceData, DateTime eventDate) {
    for (int i = 0; i < priceData.length; i++) {
      if (priceData[i].date.isAtSameMomentAs(eventDate) ||
          (i > 0 &&
              priceData[i].date.isAfter(eventDate) &&
              priceData[i - 1].date.isBefore(eventDate))) {
        return i;
      }
    }
    return -1; // Event date not found in price data
  }

  // Build event markers for the chart as dots on the price line
  List<LineChartBarData> _buildEventMarkers(
      List<PriceData> priceData,
      List<EventData> events,
      double minPrice,
      double maxPrice,
      MarketWatchProvider marketWatch) {
    List<LineChartBarData> eventMarkers = [];

    for (int i = 0; i < events.length; i++) {
      final event = events[i];
      final eventIndex = _findEventDateIndex(priceData, event.date);
      if (eventIndex == -1)
        continue; // Skip if event date not found in price data

      final eventColor = eventColors[event.type] ?? Colors.grey;
      final eventPrice = priceData[eventIndex].price;

      // Get dot size based on event type (more important events = larger dots)
      double dotSize = _getEventDotSize(event.type);

      // Check if this dot is hovered or selected for animation
      final isHovered = marketWatch.hoveredEventDots.contains(i);
      final isSelected = marketWatch.selectedEventDot == i;

      // Scale factor for animations
      double scaleFactor = 1.0;
      if (isHovered) scaleFactor = 1.2;
      if (isSelected) scaleFactor = 1.4;

      eventMarkers.add(
        LineChartBarData(
          spots: [
            FlSpot(eventIndex.toDouble(), eventPrice),
          ],
          color: eventColor,
          barWidth: 0, // No line, just dots
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: dotSize * scaleFactor,
                color: eventColor,
                strokeWidth: isHovered || isSelected ? 3 : 2,
                strokeColor: Colors.white, // White border for contrast
              );
            },
          ),
          belowBarData: BarAreaData(show: false),
        ),
      );
    }

    return eventMarkers;
  }

  // Get dot size based on event type
  double _getEventDotSize(String eventType) {
    switch (eventType) {
      case 'Split':
        return 6.0; // Largest - most significant event
      case 'Bonus':
        return 5.5; // Large - very important
      case 'Rights':
        return 5.0; // Medium-large - important
      case 'Dividend':
        return 4.5; // Medium - regular event
      case 'Announcement':
        return 4.0; // Smallest - informational
      default:
        return 4.0;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.read(themeProvider);
      final marketWatch = ref.watch(marketWatchProvider);
      
      // Convert API data to PriceData format when provider data changes
      if (marketWatch.eodChartData.isNotEmpty) {
        print(
            "EOD Chart Data from provider: ${marketWatch.eodChartData.length} items for timeframe: ${marketWatch.selectedTimeframe}");
        _convertApiDataToPriceData(
            marketWatch.eodChartData, marketWatch.selectedTimeframe);
        print("Converted price data length: ${priceData.length}");
      } else {
        print(
            "EOD Chart Data is empty for timeframe: ${marketWatch.selectedTimeframe}");
        priceData = [];
      }

      // Convert market watch event data when available
      if (marketWatch.fundamentalData?.stockEvents != null) {
        _convertMarketWatchEventData(marketWatch);
      }

      // Show loading indicator if still loading
      if (_isLoadingNewData) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: false,
            elevation: 1,
            leadingWidth: 48,
            titleSpacing: 0,
            leading: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                customBorder: const CircleBorder(),
                splashColor: Colors.grey.withOpacity(0.4),
                highlightColor: Colors.grey.withOpacity(0.2),
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.arrow_back_ios_outlined,
                    size: 18,
                    color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  ),
                ),
              ),
            ),
            title: TextWidget.titleText(
              text: "${widget.wlValue.symbol.toUpperCase()} Fundamental",
              color: Color(theme.isDarkMode ? 0xffffffff : 0xff000000),
              theme: theme.isDarkMode,
              fw: 1,
            ),
          ),
          body: _buildLoadingIndicator(theme),
        );
      }

      // Check if fundamental data is available, if not show error message
      if (!_isFundamentalDataAvailable(marketWatch)) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: false,
            elevation: 1,
            leadingWidth: 48,
            titleSpacing: 0,
            leading: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                customBorder: const CircleBorder(),
                splashColor: Colors.grey.withOpacity(0.4),
                highlightColor: Colors.grey.withOpacity(0.2),
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.arrow_back_ios_outlined,
                    size: 18,
                    color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  ),
                ),
              ),
            ),
            title: TextWidget.titleText(
              text: "${widget.wlValue.symbol.toUpperCase()} Fundamental",
              color: Color(theme.isDarkMode ? 0xffffffff : 0xff000000),
              theme: theme.isDarkMode,
              fw: 1,
            ),
          ),
          body: const Center(
            child: NoDataFound(),
          ),
        );
      }

      // Returns data is now available directly from fundamental API
      // No need to calculate it separately

      return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          elevation: _hasScrolled ? 2 : 1,
          leadingWidth: 48,
          titleSpacing: 0,
          leading: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              customBorder: const CircleBorder(),
              splashColor: Colors.grey.withOpacity(0.4),
              highlightColor: Colors.grey.withOpacity(0.2),
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_back_ios_outlined,
                  size: 18,
                  color:
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                ),
              ),
            ),
          ),
          shadowColor:
              theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
          title: TextWidget.headText(
            text: " ${widget.wlValue.symbol.replaceAll("-EQ", "").toUpperCase()}${widget.wlValue.expDate} ${widget.wlValue.option} Stock Report",
            color: Color(theme.isDarkMode ? 0xffffffff : 0xff000000),
            theme: theme.isDarkMode,
            fw: 1,
          ),
        ),
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
            child: Consumer(
              builder: (context, ref, child) {
                final marketWatch = ref.watch(marketWatchProvider);
                
                return NotificationListener<ScrollNotification>(
                      onNotification: (scrollNotification) {
                        if (scrollNotification is ScrollUpdateNotification) {
                          setState(() {
                            _hasScrolled = scrollNotification.metrics.pixels > 0;
                          });
                        }
                        return true;
                      },
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Section
                            _buildHeaderSection(theme, marketWatch),
                            const SizedBox(height: 24),

                            // Company Overview Section
                            // _buildCompanyOverviewSection(theme),
                            // const SizedBox(height: 24),

                            // // Rewards (Investment Thesis & Recommendation) Section
                            // _buildRewardsSection(theme),
                            // const SizedBox(height: 24),

                            // // Risks Section
                            // _buildRisksSection(theme),
                            // const SizedBox(height: 24),

                            // Price History & Performance Chart
                            _buildPriceHistoryChart(theme, marketWatch),
                            const SizedBox(height: 16),

                            // Key Indicators - Always show section, but hide content when no data
                            _buildRatiosTab(marketWatch, theme),
                            const SizedBox(height: 16),

                            _buildHoldingsTab(marketWatch, theme),
                            const SizedBox(height: 16),

                            _buildFinancialTab(marketWatch, theme),
                            const SizedBox(height: 16),

                            _buildPeersTab(marketWatch, theme),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    );
              },
            ),
          ),
        ),
      );
    });
  }

  // Header Section
  Widget _buildHeaderSection(
      ThemesProvider theme, MarketWatchProvider marketWatch) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Symbol (like in scrip_depth_info.dart)
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget.titleText(
                    text:
                        "${widget.wlValue.symbol.replaceAll("-EQ", "").toUpperCase()}${widget.wlValue.expDate} ${widget.wlValue.option}",
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    theme: theme.isDarkMode,
                    fw: 0,
                  ),
                  const SizedBox(height: 8),
                  TextWidget.paraText(
                    text: marketWatch.fundamentalData?.fundamental?.isNotEmpty ==
                            true
                        ? marketWatch.fundamentalData!.fundamental!.first
                                .companyName ??
                            marketWatch.scripInfoModel?.cname ??
                            widget.wlValue.symbol.toUpperCase()
                        : marketWatch.scripInfoModel?.cname ??
                            widget.wlValue.symbol.toUpperCase(),
                    theme: theme.isDarkMode,
                    fw: 0,
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                  ),
                ],
              ),
              RepaintBoundary(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextWidget.titleText(
                      text:
                          "${widget.depthData.lp != "null" ? widget.depthData.lp ?? widget.depthData.c ?? 0.00 : '0.00'}",
                      color: (widget.depthData.chng == "null" ||
                                  widget.depthData.chng == null) ||
                              widget.depthData.chng == "0.00"
                          ? theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight
                          : widget.depthData.chng!.startsWith("-") ||
                                  widget.depthData.pc!.startsWith("-")
                              ? theme.isDarkMode
                                  ? colors.lossDark
                                  : colors.lossLight
                              : theme.isDarkMode
                                  ? colors.profitDark
                                  : colors.profitLight,
                      theme: theme.isDarkMode,
                      fw: 0,
                    ),
                    const SizedBox(height: 8),
            
                    // Price Change and Percentage
                    TextWidget.paraText(
                      text:
                          "${(double.tryParse(widget.depthData.chng ?? '0.00') ?? 0.00).toStringAsFixed(2)} (${(double.tryParse(widget.depthData.pc ?? '0.00') ?? 0.00).toStringAsFixed(2)}%)",
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      theme: theme.isDarkMode,
                      fw: 0,
                    ),
                    // const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),

        // // Sector Information
        // TextWidget.paraText(
        //   text: "Sector: Energy – Oil & Gas – Refineries (Large‑Cap)",
        //   theme: theme.isDarkMode,
        //   fw: 0,
        //   color: theme.isDarkMode
        //       ? colors.textSecondaryDark
        //       : colors.textSecondaryLight,
        // ),
      ],
    );
  }
 Widget _buildRatiosTab(
      MarketWatchProvider marketWatch, ThemesProvider theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colors.textSecondaryLight.withOpacity(0.1)),
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget.titleText(
            text: "Key indicators",
            theme: theme.isDarkMode,
            fw: 1,
          ),
          const SizedBox(height: 16),
          // Show data if available, otherwise show "No Data Found"
          if (marketWatch.fundamentalData?.fundamental?.isNotEmpty == true) ...[
            _buildRatiosSection(marketWatch.fundamentalData!.fundamental![0], theme),
          ] else ...[
            SizedBox(height: 250, child:  Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // SvgPicture.asset(assets.noDatafound,
        // color:   Color(0xff777777)
        // ),
        // const SizedBox(height: 2),
        SizedBox(
          width: 250,
          child: TextWidget.subText(
              text: "Data not available",
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
                  fw:0,
                  align: TextAlign.center,
              theme: theme.isDarkMode),
        )
      ]
    ))),
          ],
          
        ],
      ),
    );
  }


   Widget _buildRatiosSection(dynamic funData, ThemesProvider theme) {
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         // VALUE SECTION

          _rowOfInfoData(
           "MARKET CAP",
           "${funData?.marketCap != null ? double.parse(funData!.marketCap!).round() : 'N/A'} Cr",
           "FACE VALUE",
           "${funData?.fv ?? 'N/A'}",
           "",
           "",
           theme,
         ),
         const SizedBox(height: 14),
         _buildSectionHeader("Value", theme),
         const SizedBox(height: 12),
         _rowOfInfoData(
           "P/E",
           "${funData?.pe ?? 'N/A'}",
           "SECTOR PE",
           "${funData?.sectorPe ?? 'N/A'}",
           "EV/EBITDA",
           "${funData?.evEbitda ?? 'N/A'}",
           theme,
         ),
         const SizedBox(height: 14),
         _rowOfInfoData(
           "P/B",
           "${funData?.priceBookValue ?? 'N/A'}",          
           "P/S",
           "${funData?.salesToWorkingCapital ?? 'N/A'}",
            "DIVIDEND YIELD",
           "${funData?.dividendYieldPercent ?? 'N/A'}",
           theme,
         ),
         const SizedBox(height: 20),
         
         // GROWTH SECTION
         _buildSectionHeader("Growth", theme),
         const SizedBox(height: 12),
         _rowOfInfoData(
           "EPS",
           "${funData?.eps ?? 'N/A'}",
           "BOOK VALUE",
           "${funData?.bookValue ?? 'N/A'}",
           "",
           "",
           theme,
         ),
         const SizedBox(height: 20),
         
         // QUALITY SECTION
         _buildSectionHeader("Quality", theme),
         const SizedBox(height: 12),
         _rowOfInfoData(
           "ROCE",
           "${funData?.rocePercent ?? 'N/A'}",
           "ROE",
           "${funData?.roePercent ?? 'N/A'}",
           "D/E",
           "${funData?.debtToEquity ?? 'N/A'}",
           theme,
         ),
        //  const SizedBox(height: 14),
        //  _rowOfInfoData(
        //    "FACE VALUE",
        //    "${funData?.fv ?? 'N/A'}",
        //    "",
        //    "",
        //    "",
        //    "",
        //    theme,
        //  ),
       ],
     );
   }

  Widget _buildSectionHeader(String title, ThemesProvider theme) {
    return Row(
      children: [
        TextWidget.subText(
          text: title,
          theme: theme.isDarkMode,
          fw: 0,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
        ),
        if (title == "Value" || title == "Growth" || title == "Quality") ...[
          const SizedBox(width: 4),
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              splashColor:
                  theme.isDarkMode ? colors.splashColorDark : colors.splashColorLight,
              highlightColor:
                  theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
              onTap: () {}, // required for splash
              child: TooltipTheme(
                data: TooltipThemeData(
                  textStyle: TextWidget.textStyle(
                    fontSize: 12,
                    theme: false,
                    color: Colors.white,
                    fw: 0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  preferBelow: false,
                  verticalOffset: 8,
                ),
                child: Tooltip(
                  message: _getSectionTooltip(title),
                  triggerMode: TooltipTriggerMode.tap,
                  waitDuration: const Duration(milliseconds: 80),
                  showDuration: const Duration(seconds: 5),
                  preferBelow: false,
                  verticalOffset: 8,
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: Center(
                      child: Icon(
                        Icons.info_outline,
                        size: 18,
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Info tooltip removed

  String _getSectionTooltip(String sectionTitle) {
    switch (sectionTitle) {
      case "Value":
        return "P/E - Price-to-Earnings\nP/B - Price-to-Book\nP/S - Price-to-Sales";
      
      case "Growth":
        return "EPS - Earnings Per Share";
      
      case "Quality":
        return "ROCE - Return on Capital Employed\nROE - Return on Equity\nD/E - Debt-to-Equity";
      
      default:
        return "Financial metrics";
    }
  }

  Row _rowOfInfoData(String title1, String value1, String title2, String value2,
      String title3, String value3, ThemesProvider theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget.captionText(
                text: title1,
                color: const Color(0xff666666),
                theme: theme.isDarkMode,
                fw: 0,
              ),
              const SizedBox(height: 4),
              TextWidget.subText(
                text: _formatNumber(value1, title1),
                theme: theme.isDarkMode,
                fw: 1,
              ),
              const SizedBox(height: 2),
              Divider(
                color: theme.isDarkMode
                    ? colors.darkColorDivider
                    : colors.colorDivider,
              ),
            ],
          ),
        ),
        if (title2.isNotEmpty) ...[
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget.captionText(
                  text: title2,
                  color: const Color(0xff666666),
                  theme: theme.isDarkMode,
                  fw: 0,
                ),
                const SizedBox(height: 4),
                TextWidget.subText(
                  text: _formatNumber(value2, title2),
                  theme: theme.isDarkMode,
                  fw: 1,
                ),
                const SizedBox(height: 2),
                Divider(
                  color: theme.isDarkMode
                      ? colors.darkColorDivider
                      : colors.colorDivider,
                ),
              ],
            ),
          ),
        ],
        if (title3.isNotEmpty) ...[
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget.captionText(
                  text: title3,
                  color: const Color(0xff666666),
                  theme: theme.isDarkMode,
                  fw: 0,
                ),
                const SizedBox(height: 4),
                TextWidget.subText(
                  text: _formatNumber(value3, title3),
                  theme: theme.isDarkMode,
                  fw: 1,
                ),
                const SizedBox(height: 2),
                Divider(
                  color: theme.isDarkMode
                      ? colors.darkColorDivider
                      : colors.colorDivider,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _formatNumber(String value, String title) {
    if (value == 'N/A' || value.isEmpty) return value;
    
    final numValue = double.tryParse(value);
    if (numValue == null) return value;
    
 
    
    // For other values, just format to 2 decimal places if needed
    if (numValue % 1 == 0) {
      return numValue.toInt().toString();
    } else {
      return numValue.toStringAsFixed(2);
    }
  }



  // Company Overview Section
  Widget _buildCompanyOverviewSection(ThemesProvider theme) {
    return _buildSectionCard(
      "Overview",
      Icons.business,
      [
        _buildOverviewItem(
          "Core Business",
          "Global leader in IT services, consulting, and business solutions with expertise in digital transformation, cloud services, and enterprise software development.",
          theme,
        ),
        const SizedBox(height: 16),
        _buildOverviewItem(
          "Strategic Diversification",
          "Expansion into emerging technologies including AI/ML, blockchain, IoT solutions, and industry-specific digital platforms across banking, retail, and healthcare.",
          theme,
        ),
        const SizedBox(height: 16),
        _buildOverviewItem(
          "Competitive Advantage",
          "World-class talent pool with 600,000+ employees, strong client relationships with Fortune 500 companies, and proven delivery capabilities across 46+ countries.",
          theme,
        ),
        const SizedBox(height: 16),
        _buildOverviewItem(
          "Capital Allocation",
          "Talent development, R&D investments, and strategic acquisitions while maintaining strong cash generation and consistent dividend distribution.",
          theme,
        ),
      ],
      theme,
    );
  }

  // Rewards (Investment Thesis & Recommendation) Section
  Widget _buildRewardsSection(ThemesProvider theme) {
    return _buildSectionCard(
      "Rewards",
      Icons.trending_up,
      [
        _buildRewardItem(
          "Diversified earnings base",
          "Oil & gas, telecom, retail, and renewables provide multiple growth levers.",
          theme,
        ),
        const SizedBox(height: 12),
        _buildRewardItem(
          "Strong cash generation",
          "Operating cash flow > ₹ 170 bn, enabling self-financed capex.",
          theme,
        ),
        const SizedBox(height: 12),
        _buildRewardItem(
          "Modest leverage",
          "Debt-to-equity ≈ 0.36, well-below many peers.",
          theme,
        ),
        const SizedBox(height: 12),
        _buildRewardItem(
          "Valuation premium justified?",
          "PE and EV/EBITDA are higher than peers; price must reflect high-growth segments.",
          theme,
        ),
        const SizedBox(height: 12),
        _buildRewardItem(
          "Upside catalysts",
          "5G rollout, green-hydrogen projects, retail-to-consumer expansion, and potential strategic acquisitions.",
          theme,
        ),
        const SizedBox(height: 12),
        _buildRewardItem(
          "Downside guardrails",
          "Even a 15% price decline leaves the stock above book value (PB ≈ 1.8x) with ample cash coverage.",
          theme,
        ),
      ],
      theme,
    );
  }

  // Risks Section
  Widget _buildRisksSection(ThemesProvider theme) {
    return _buildSectionCard(
      "Key Risks to Watch",
      Icons.warning_amber,
      [
        _buildRiskItem(
          "Sharp decline in global crude-oil prices compressing refining margins.",
          theme,
        ),
        const SizedBox(height: 12),
        _buildRiskItem(
          "Regulatory/tax reforms affecting the oil-and-gas and renewable-energy segments.",
          theme,
        ),
        const SizedBox(height: 12),
        _buildRiskItem(
          "Execution risk on large-scale capex (green-hydrogen, 5G) – cost overruns could erode cash flow.",
          theme,
        ),
        const SizedBox(height: 12),
        _buildRiskItem(
          "Intensifying competition in telecom and retail, potentially slowing high-margin growth.",
          theme,
        ),
        const SizedBox(height: 12),
        _buildRiskItem(
          "Macroeconomic slowdown reducing demand for petrochemicals and discretionary retail spend.",
          theme,
        ),
      ],
      theme,
    );
  }

  Widget _buildPeersTab(MarketWatchProvider marketWatch, ThemesProvider theme) {
    // Show data if available, otherwise show "No Data Found"
    if (marketWatch.fundamentalData?.msg != "no data found" &&
        marketWatch.fundamentalData?.peersComparison != null &&
        marketWatch.fundamentalData!.peersComparison!.stock != null &&
        marketWatch.fundamentalData!.peersComparison!.peers != null &&
        (marketWatch.fundamentalData!.peersComparison!.stock!.isNotEmpty ||
         marketWatch.fundamentalData!.peersComparison!.peers!.isNotEmpty)) {
      return const PriceComparision();
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget.titleText(
            text: "Peers Comparison",
            theme: theme.isDarkMode,
            fw: 1,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
          ),
          const SizedBox(height: 16),
           SizedBox(height: 250, child:  Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // SvgPicture.asset(assets.noDatafound,
        // color:   Color(0xff777777)
        // ),
        // const SizedBox(height: 2),
        SizedBox(
          width: 250,
          child: TextWidget.subText(
              text: "Data not available",
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
                  fw:0,
                  align: TextAlign.center,
              theme: theme.isDarkMode),
        )
      ]
    )))
        ],
      );
    }
  }

  Widget _buildHoldingsTab(
      MarketWatchProvider marketWatch, ThemesProvider theme) {
    return Column(
      children: [
        // Pie Chart Section
    
        // Original Bar Chart Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border:
                Border.all(color: colors.textSecondaryLight.withOpacity(0.1)),
            color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget.titleText(
                text: "Holdings Trend",
                theme: theme.isDarkMode,
                fw: 1,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
              ),
              const SizedBox(height: 24),
    
              // Show data if available, otherwise show "No Data Found"
              if (marketWatch.fundamentalData?.msg != "no data found" &&
                  marketWatch.fundamentalData?.shareholdings != null &&
                  marketWatch.fundamentalData!.shareholdings!.isNotEmpty) ...[
                // Pie Chart Container
                _buildHoldingsPieChart(marketWatch, theme),
                const SizedBox(height: 16),
    
                // Holdings Table
                _buildHoldingsTable(marketWatch, theme),
              ] else ...[
                SizedBox(height: 250, child:  Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // SvgPicture.asset(assets.noDatafound,
        // color:   Color(0xff777777)
        // ),
        // const SizedBox(height: 2),
        SizedBox(
          width: 250,
          child: TextWidget.subText(
              text: "Data not available",
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
                  fw:0,
                  align: TextAlign.center,
              theme: theme.isDarkMode),
        )
      ]
    ))),
              ],
              // const ShareHoldChart(),
              // const SizedBox(height: 16),
              // Container(
              //   margin: const EdgeInsets.only(bottom: 16),
              //   child: Wrap(
              //     alignment: WrapAlignment.start,
              //     spacing: 16,
              //     runSpacing: 12,
              //     children: marketWatch.shareHoldType.map((holdType) {
              //       final isSelected = marketWatch.selctedShareHold == holdType;
              //       return GestureDetector(
              //         onTap: () {
              //           print("Selected Share Hold: $holdType");
              //           marketWatch.chngshareHold(holdType);
              //         },
              //         child: Container(
              //           padding: const EdgeInsets.symmetric(
              //               horizontal: 12, vertical: 8),
              //           decoration: BoxDecoration(
              //             color: isSelected
              //                 ? theme.isDarkMode
              //                     ? colors.darkGrey
              //                     : const Color(0xffF1F3F8)
              //                 : Colors.transparent,
              //             borderRadius: BorderRadius.circular(8),
              //             border: isSelected
              //                 ? null
              //                 : null,
              //           ),
              //           child: Row(
              //             mainAxisSize: MainAxisSize.min,
              //             children: [
              //               Container(
              //                 width: 8,
              //                 height: 8,
              //                 decoration: BoxDecoration(
              //                   color: _getHoldTypeColor(holdType),
              //                   shape: BoxShape.circle,
              //                 ),
              //               ),
              //               const SizedBox(width: 8),
              //               TextWidget.captionText(
              //                 text: holdType,
              //                 theme: theme.isDarkMode,
              //                 color: theme.isDarkMode
              //                     ? colors.textPrimaryDark
              //                     : colors.textPrimaryLight,
              //                 fw: isSelected ? 2 : 0,
              //               ),
              //             ],
              //           ),
              //         ),
              //       );
              //     }).toList(),
              //   ),
              // ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method to get color for each holding type
  Color _getHoldTypeColor(String holdType) {
    switch (holdType) {
      case "Promoter Holding":
        return const Color(0xFF2196F3); // Blue
      case "Foriegn Institution":
        return const Color(0xFF4CAF50); // Green
      case "Other Domestic Institution":
        return const Color(0xFFFF9800); // Orange
      case "Retail and Others":
        return const Color(0xFF9C27B0); // Purple
      case "Mutual Funds":
        return const Color(0xFFE91E63); // Pink
      default:
        return const Color(0xFF607D8B); // Blue Grey
    }
  }

  // Section Card Helper
  Widget _buildSectionCard(String title, IconData icon, List<Widget> children,
      ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TextWidget.titleText(
              text: title,
              theme: theme.isDarkMode,
              fw: 1,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  // Overview Item Helper
  Widget _buildOverviewItem(
      String title, String description, ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget.subText(
          text: title,
          theme: theme.isDarkMode,
          fw: 1,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
        ),
        const SizedBox(height: 6),
        TextWidget.paraText(
          text: description,
          theme: theme.isDarkMode,
          fw: 0,
          color: theme.isDarkMode
              ? colors.textSecondaryDark
              : colors.textSecondaryLight,
        ),
      ],
    );
  }

  // Reward Item Helper
  Widget _buildRewardItem(
      String title, String description, ThemesProvider theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 6, right: 12),
          decoration: BoxDecoration(
            color: theme.isDarkMode ? colors.profitDark : colors.profitLight,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget.subText(
                text: title,
                theme: theme.isDarkMode,
                fw: 1,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
              ),
              const SizedBox(height: 4),
              TextWidget.paraText(
                text: description,
                theme: theme.isDarkMode,
                fw: 0,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialTab(
      MarketWatchProvider marketWatch, ThemesProvider theme) {
    if (marketWatch.fundamentalData?.msg == "no data found") {
      return const Center(child: NoDataFound());
    }

    return const SingleChildScrollView(
      // padding: EdgeInsets.all(16),
      child: FinancialWidget(),
    );
  }

  // Check if fundamental data is available
  bool _isFundamentalDataAvailable(MarketWatchProvider marketWatch) {
    return marketWatch.fundamentalData != null &&
           marketWatch.fundamentalData?.msg != "no data found";
  }

  // Risk Item Helper
  Widget _buildRiskItem(String description, ThemesProvider theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 6, right: 12),
          decoration: BoxDecoration(
            color: theme.isDarkMode ? colors.lossDark : colors.lossLight,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: TextWidget.paraText(
            text: description,
            theme: theme.isDarkMode,
            fw: 0,
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  // Price History & Performance Chart
  Widget _buildPriceHistoryChart(
      ThemesProvider theme, MarketWatchProvider marketWatch) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      decoration: BoxDecoration(
        // border: Border.all(color: colors.textSecondaryLight.withOpacity(0.1)),
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Toggle
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // TextWidget.titleText(
              //   text: "Price History & Performance",
              //   theme: theme.isDarkMode,
              //   fw: 1,
              //   color: theme.isDarkMode
              //       ? colors.textPrimaryDark
              //       : colors.textPrimaryLight,
              // ),
              // const SizedBox(height: 16),

              Container(
                height: 400,
                decoration: BoxDecoration(
                  color:
                      theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                ),
                child: marketWatch.chartDataLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: theme.isDarkMode
                              ? colors.primaryDark
                              : colors.primaryLight,
                        ),
                      )
                    : priceData.isEmpty
                        ? Center(
                            child: TextWidget.paraText(
                              text: "No Data Available",
                              theme: theme.isDarkMode,
                              fw: 0,
                              color: theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                            ),
                          )
                        : _buildScrollablePriceChart(theme, marketWatch),
              ),


              SizedBox(
                height: 50, 
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final timeframes = ["1W", "1M", "3M", "1Y"];
                    final timeframe = timeframes[index];
                    final isSelected =
                        marketWatch.selectedTimeframe == timeframe;
                    
                    final returnPercentage = _getTechnicalReturnPercentage(marketWatch.returnsGridview, timeframe);
                    
                    final percentValue = double.tryParse(returnPercentage.replaceAll(RegExp(r'[+%]'), '')) ?? 0.0;
                    final isPositive = percentValue >= 0;
              
                    return GestureDetector(
                      onTap: () {
                        marketWatch.updateSelectedTimeframe(timeframe);
                        // Hide tooltip when timeframe changes
                        marketWatch.updateShowTooltip(false);
                        touchedSpot = null;
                        _hideTooltipTimer?.cancel();
                        FocusScope.of(context).unfocus();
              
                        print("Filtering data for timeframe: $timeframe");
                        if (marketWatch.eodChartData.isNotEmpty) {
                          _convertApiDataToPriceData(marketWatch.eodChartData, timeframe);
                          print("Converted price data length: ${priceData.length}");
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.isDarkMode
                                  ? colors.darkGrey
                                  : const Color(0xffF1F3F8)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Timeframe text
                            TextWidget.paraText(
                              text: timeframe,
                              theme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? colors.textPrimaryDark
                                  : colors.textPrimaryLight,
                              fw: isSelected ? 2 : 0,
                            ),
                            const SizedBox(height: 4
                            ),
                            // Return percentage
                            TextWidget.paraText(
                              text: returnPercentage,
                              theme: theme.isDarkMode,
                              color: isPositive
                                  ? (theme.isDarkMode
                                      ? colors.profitDark
                                      : colors.profitLight)
                                  : (theme.isDarkMode
                                      ? colors.lossDark
                                      : colors.lossLight),
                              fw: isSelected ? 1 : 0,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(width: 4);
                  },
                  itemCount: 4, // 1W, 1M, 3M, 1Y
                ),
              ),
            ],
          ),
          if (eventData.isNotEmpty) ...[
            // const SizedBox(height: 16),
            _buildEventLegend(theme),
          ],
        ],
      ),
    );
  }

  // Non-scrollable Price Chart - fits 1 year data within screen
  Widget _buildScrollablePriceChart(
      ThemesProvider theme, MarketWatchProvider marketWatch) {
    if (priceData.isEmpty) return const SizedBox();

    final minPrice = priceData.map((e) => e.price).reduce(math.min);
    final maxPrice = priceData.map((e) => e.price).reduce(math.max);

    return Container(
      height: 400, 
      padding: const EdgeInsets.only(
          top: 16, bottom: 16, left: 8, right: 8), 
      child: Stack(
        children: [
          AnimatedSwitcher(
            duration: Duration.zero, 
            child: LineChart(
              key: ValueKey(marketWatch
                  .selectedTimeframe), 
              LineChartData(
                gridData: const FlGridData(
                  show: false, 
                  drawVerticalLine: false,
                  drawHorizontalLine: false,
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      interval: (priceData.length - 1) /
                          4, 
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < priceData.length) {
                          final date = priceData[value.toInt()].date;
                          final months = [
                            'Jan',
                            'Feb',
                            'Mar',
                            'Apr',
                            'May',
                            'Jun',
                            'Jul',
                            'Aug',
                            'Sep',
                            'Oct',
                            'Nov',
                            'Dec'
                          ];

                          switch (marketWatch.selectedTimeframe) {
                            case "1Y":
                              
                              final monthName = months[date.month - 1];
                              final year = date.year.toString().substring(2);
                              return TextWidget.captionText(
                                text: '$monthName $year',
                                theme: theme.isDarkMode,
                                fw: 0,
                                color: theme.isDarkMode
                                    ? colors.textSecondaryDark
                                    : colors.textSecondaryLight,
                              );
                            case "3M":
                              // For 3M view, show month and day
                              final monthName = months[date.month - 1];
                              final day = date.day;
                              return TextWidget.captionText(
                                text: '$monthName $day',
                                theme: theme.isDarkMode,
                                fw: 0,
                                color: theme.isDarkMode
                                    ? colors.textSecondaryDark
                                    : colors.textSecondaryLight,
                              );
                            case "1M":
                              // For 1M view, show day only
                              final day = date.day;
                              return TextWidget.captionText(
                                text: '$day',
                                theme: theme.isDarkMode,
                                fw: 0,
                                color: theme.isDarkMode
                                    ? colors.textSecondaryDark
                                    : colors.textSecondaryLight,
                              );
                            case "1W":
                              // For 1W view, show day and month
                              final monthName = months[date.month - 1];
                              final day = date.day;
                              return TextWidget.captionText(
                                text: '$day $monthName',
                                theme: theme.isDarkMode,
                                fw: 0,
                                color: theme.isDarkMode
                                    ? colors.textSecondaryDark
                                    : colors.textSecondaryLight,
                              );
                            default:
                              return const SizedBox();
                          }
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                clipData: const FlClipData.all(),
                minY: (minPrice - (maxPrice - minPrice) * 0.08) <= 0
                    ? 0
                    : minPrice - (maxPrice - minPrice) * 0.08,
                maxY: maxPrice + (maxPrice - minPrice) * 0.06,
                lineBarsData: [
                  // Main price line
                  LineChartBarData(
                    spots: priceData.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.price);
                    }).toList(),
                    isCurved: true,
                    color: theme.isDarkMode
                        ? colors.primaryDark
                        : colors.primaryLight,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: false,
                    ),
                    belowBarData: BarAreaData(
                        show: false), // Remove blue area below chart
                  ),
                  // Event markers as vertical lines
                  ..._buildEventMarkers(
                      priceData, eventData, minPrice, maxPrice, marketWatch),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((touchedSpot) => null).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                  getTouchedSpotIndicator:
                      (LineChartBarData barData, List<int> spotIndexes) {
                    return spotIndexes.map((spotIndex) {
                      return TouchedSpotIndicatorData(
                        FlLine(
                          color: theme.isDarkMode
                              ? colors.primaryDark
                              : colors.primaryLight,
                          strokeWidth: 1, // Thin vertical line
                          dashArray: [3, 3], // Dashed line for cleaner look
                        ),
                        FlDotData(
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 3, // Smaller circle
                              color: theme.isDarkMode
                                  ? colors.primaryDark
                                  : colors.primaryLight,
                              strokeWidth: 2, // Thinner border
                              strokeColor: theme.isDarkMode
                                  ? colors.colorBlack
                                  : colors.colorWhite,
                            );
                          },
                        ),
                      );
                    }).toList();
                  },
                  touchCallback:
                      (FlTouchEvent event, LineTouchResponse? touchResponse) {
                    if (event is FlTapUpEvent ||
                        event is FlPanUpdateEvent ||
                        event is FlPanStartEvent ||
                        event is FlTapDownEvent ||
                        event is FlLongPressStart ||
                        event is FlLongPressEnd ||
                        event is FlLongPressMoveUpdate) {
                      if (touchResponse != null &&
                          touchResponse.lineBarSpots != null &&
                          touchResponse.lineBarSpots!.isNotEmpty) {
                        final spot = touchResponse.lineBarSpots!.first;
                        final index = spot.x.toInt();

                        if (index >= 0 && index < priceData.length) {
                          // Check if touch is near an event dot
                          final touchedDate = priceData[index].date;
                          final nearbyEvents = _getEventsNearDate(touchedDate);

                          touchedSpot = FlSpot(index.toDouble(), spot.y);
                          marketWatch.updateShowTooltip(true);
                          marketWatch.updateSelectedIndex(index);

                          // Update hovered event dots
                          final newHoveredDots = nearbyEvents
                              .map((e) => eventData.indexOf(e))
                              .toSet();
                          marketWatch.updateHoveredEventDots(newHoveredDots);

                          // Select the closest event if any
                          if (nearbyEvents.isNotEmpty) {
                            final eventDotIndex =
                                eventData.indexOf(nearbyEvents.first);
                            marketWatch.updateSelectedEventDot(eventDotIndex);
                            print(
                                "Event dot highlighted: ${nearbyEvents.first.title}");
                          } else {
                            marketWatch.updateSelectedEventDot(null);
                            print(
                                "No nearby events found for date: ${touchedDate}");
                          }

                          // Only set auto-hide timer for tap events, not for continuous interactions
                          if (event is FlTapUpEvent ||
                              event is FlPanEndEvent ||
                              event is FlLongPressEnd) {
                            _hideTooltipTimer?.cancel();
                            _hideTooltipTimer =
                                Timer(const Duration(seconds: 2), () {
                              if (mounted) {
                                marketWatch.clearChartInteractionState();
                                touchedSpot = null;
                              }
                            });
                          } else {
                            _hideTooltipTimer?.cancel();
                          }
                        }
                      }
                    } else if (event is FlPanEndEvent ||
                        event is FlTapCancelEvent) {
                      // Handle touch end/cancel events
                      _hideTooltipTimer?.cancel();
                      _hideTooltipTimer = Timer(const Duration(seconds: 2), () {
                        if (mounted) {
                          marketWatch.clearChartInteractionState();
                          touchedSpot = null;
                        }
                      });
                    }
                  },
                ),
              ),
            ),
          ), 
          if (marketWatch.showTooltip && touchedSpot != null)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color:
                      theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider,
                  ),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.black.withOpacity(0.1),
                  //     blurRadius: 4,
                  //     offset: const Offset(0, 2),
                  //   ),
                  // ],
                ),
                child: Builder(
                  builder: (context) {
                    final index = touchedSpot!.x.toInt();
                    if (index >= 0 && index < priceData.length) {
                      final data = priceData[index];
                      // Check both exact date and nearby events for tooltip
                      final exactEvents = _getEventsForDate(data.date);
                      final nearbyEvents = _getEventsNearDate(data.date);
                      final eventsForDate =
                          exactEvents.isNotEmpty ? exactEvents : nearbyEvents;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextWidget.overlineText(
                            text: _getFormattedDate(data.date),
                            theme: theme.isDarkMode,
                            fw: 1,
                            color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                          ),
                          const SizedBox(height: 4),
                          TextWidget.subText(
                            text: '₹${data.price.toStringAsFixed(2)}',
                            theme: theme.isDarkMode,
                            fw: 0,
                            color: theme.isDarkMode
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight,
                          ),
                          // Show events if any exist for this date or nearby
                          if (eventsForDate.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            ...eventsForDate.map((event) {
                              final eventColor =
                                  eventColors[event.type] ?? Colors.grey;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: eventColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                      color: eventColor.withOpacity(0.3),
                                      width: 1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: eventColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: TextWidget.captionText(
                                        text: event.type == 'Dividend'
                                            ? '${event.title} ${event.description.split(' - ')[0]}' // Show "Dividend X%"
                                            : event.title,
                                        theme: theme.isDarkMode,
                                        fw: 0,
                                        color: eventColor,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(ThemesProvider theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
          ),
          const SizedBox(height: 16),
          TextWidget.paraText(
            text: "Loading stock data...",
            theme: theme.isDarkMode,
            color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
          ),
        ],
      ),
    );
  }

  String _getTechnicalReturnPercentage(List returnsGridview, String timeframe) {
    String durationKey = '';
    
    switch (timeframe) {
      case "1W":
        durationKey = "One Week";
        break;
      case "1M":
        durationKey = "One Month";
        break;
      case "3M":
        durationKey = "Three Month";
        break;
      case "1Y":
        durationKey = "52 Week";
        break;
      default:
        durationKey = "One Week";
    }

    // Find the matching return data from technical returns
    for (var item in returnsGridview) {
      if (item['duration'] == durationKey) {
        final percent = item['percent']?.toString() ?? '0.00';
        final percentValue = double.tryParse(percent) ?? 0.0;
        final isPositive = percentValue >= 0;
        return '${isPositive ? '+' : ''}$percent%';
      }
    }
    
    return '0.00%';
  }

  // Helper method to get return percentage for a specific timeframe (keeping for backend API - not used anymore)
  String _getReturnPercentageForTimeframe(List<Returns> returnsData, String timeframe) {
    String returnKey = '';
    
    switch (timeframe) {
      case "1W":
        returnKey = "1 week";
        break;
      case "1M":
        returnKey = "1 month";
        break;
      case "3M":
        returnKey = "3 month";
        break;
      case "1Y":
        returnKey = "1 year";
        break;
      default:
        returnKey = "1 week";
    }

    // Find the matching return data
    final returnItem = returnsData.firstWhere(
      (item) => item.type == returnKey,
      orElse: () => Returns(returns: "0.00", type: timeframe),
    );

    final percent = returnItem.returns ?? '0.00';
    final percentValue = double.tryParse(percent) ?? 0.0;
    final isPositive = percentValue >= 0;
    
    return '${isPositive ? '+' : ''}$percent%';
  }

 

  // Build returns grid display (keeping for future use)
  Widget _buildReturnsGrid(List<Returns> returnsData, ThemesProvider theme) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: returnsData.map<Widget>((returnItem) {
        final duration = returnItem.type ?? '';
        final percent = returnItem.returns ?? '0.00';
        final percentValue = double.tryParse(percent) ?? 0.0;
        final isPositive = percentValue >= 0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isPositive
                ? (theme.isDarkMode
                    ? colors.profitDark.withOpacity(0.1)
                    : colors.profitLight.withOpacity(0.1))
                : (theme.isDarkMode
                    ? colors.lossDark.withOpacity(0.1)
                    : colors.lossLight.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isPositive
                  ? (theme.isDarkMode ? colors.profitDark : colors.profitLight)
                  : (theme.isDarkMode ? colors.lossDark : colors.lossLight),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextWidget.captionText(
                text: duration,
                theme: theme.isDarkMode,
                fw: 0,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
              ),
              const SizedBox(width: 4),
              TextWidget.captionText(
                text: '${isPositive ? '+' : ''}$percent%',
                theme: theme.isDarkMode,
                fw: 1,
                color: isPositive
                    ? (theme.isDarkMode
                        ? colors.profitDark
                        : colors.profitLight)
                    : (theme.isDarkMode ? colors.lossDark : colors.lossLight),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Helper method to format date for tooltip
  String _getFormattedDate(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final weekday = weekdays[date.weekday - 1];
    final day = date.day;
    final month = months[date.month - 1];
    final year = date.year;

    return '$weekday, $day $month $year';
  }

  // Smart tooltip positioning based on available space
  double _getSmartTooltipPosition(double touchX, double chartWidth) {
    const tooltipWidth = 120.0; // Approximate tooltip width
    const padding = 8.0; // Minimum padding from edges

    // Calculate the desired position (touch point * 4.0 for chart scaling)
    final desiredPosition = touchX * 4.0;

    // Check if tooltip would go off the right edge
    if (desiredPosition + tooltipWidth + padding > chartWidth) {
      // Position to the left of the touch point
      return (desiredPosition - tooltipWidth)
          .clamp(padding, chartWidth - tooltipWidth - padding);
    } else {
      // Position to the right of the touch point (default)
      return desiredPosition.clamp(
          padding, chartWidth - tooltipWidth - padding);
    }
  }

  // Build event legend
  Widget _buildEventLegend(ThemesProvider theme) {
    // Get unique event types from eventData
    final uniqueEventTypes = eventData.map((e) => e.type).toSet().toList();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Wrap(
        spacing: 20,
        runSpacing: 12,
        children: uniqueEventTypes.map((eventType) {
          final color = eventColors[eventType] ?? Colors.grey;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              TextWidget.custmText(
                text: eventType,
                fs: 10,
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 0,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // Get events for a specific date
  List<EventData> _getEventsForDate(DateTime date) {
    return eventData.where((event) {
      return event.date.year == date.year &&
          event.date.month == date.month &&
          event.date.day == date.day;
    }).toList();
  }

  // Get events near a specific date (within 3 days for better touch interaction)
  List<EventData> _getEventsNearDate(DateTime date) {
    return eventData.where((event) {
      final daysDifference = event.date.difference(date).inDays.abs();
      return daysDifference <= 3; // Consider events within 3 days as "nearby"
    }).toList();
  }

  // Build holdings pie chart
  Widget _buildHoldingsPieChart(
      MarketWatchProvider marketWatch, ThemesProvider theme) {
    // Get the latest data (Jun 25) from shareholdings
    final shareholdingsData = marketWatch.fundamentalData?.shareholdings;
    if (shareholdingsData == null || shareholdingsData.isEmpty) {
      return Center(
        child: TextWidget.paraText(
          text: 'No holdings data available',
          theme: theme.isDarkMode,
          fw: 0,
          color: theme.isDarkMode
              ? colors.textSecondaryDark
              : colors.textSecondaryLight,
        ),
      );
    }

    // Find the latest data (Jun 25)
    final latestData = _getLatestHoldingsData(shareholdingsData);
    if (latestData == null) {
      return Center(
        child: TextWidget.paraText(
          text: 'No latest holdings data available',
          theme: theme.isDarkMode,
          fw: 0,
          color: theme.isDarkMode
              ? colors.textSecondaryDark
              : colors.textSecondaryLight,
        ),
      );
    }

    // Prepare chart data
    final chartData = _prepareShareholdersChartData(latestData);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: CustomPaint(
          size: const Size(180, 180),
          painter: ShareholdersDonutChartPainter(
            data: chartData,
            theme: theme,
          ),
        ),
      ),
    );
  }

  // Get the latest holdings data (Jun 25)
  Shareholdings? _getLatestHoldingsData(List<Shareholdings> data) {
    // Sort data to get the latest entry
    final sortedData = List<Shareholdings>.from(data);
    sortedData.sort((a, b) {
      final orderMap = {
        'Jun 24': 1,
        'Sep 24': 2,
        'Dec 24': 3,
        'Mar 25': 4,
        'Jun 25': 5,
      };
      final aOrder = orderMap[a.convDate] ?? 0;
      final bOrder = orderMap[b.convDate] ?? 0;
      return bOrder.compareTo(aOrder); // Descending order to get latest first
    });

    return sortedData.isNotEmpty ? sortedData.first : null;
  }

  // Prepare shareholders chart data from Shareholdings
  List<Map<String, dynamic>> _prepareShareholdersChartData(Shareholdings data) {
    final holdingsData = [
      {
        'name': 'Institutions',
        'value': double.tryParse(data.fiiFpi ?? '0') ?? 0.0,
        'color': const Color(0xFF2563EB), // Modern Blue
      },
      {
        'name': 'Corporation',
        'value': double.tryParse(data.mutualFunds ?? '0') ?? 0.0,
        'color': const Color(0xFFDC2626), // Modern Red
      },
      {
        'name': 'Holding Company',
        'value': double.tryParse(data.dii ?? '0') ?? 0.0,
        'color': const Color(0xFF059669), // Modern Green
      },
      {
        'name': 'Insiders',
        'value': double.tryParse(data.promoters ?? '0') ?? 0.0,
        'color': const Color(0xFF7C3AED), // Modern Purple
      },
      {
        'name': 'Others',
        'value': double.tryParse(data.retailAndOthers ?? '0') ?? 0.0,
        'color': const Color(0xFFEA580C), // Modern Orange
      },
    ];

    // Filter out zero values and calculate total
    final filteredData =
        holdingsData.where((item) => item['value'] as double > 0).toList();
    final total =
        filteredData.fold(0.0, (sum, item) => sum + (item['value'] as double));

    return filteredData.map((item) {
      final value = item['value'] as double;
      final percentage = total > 0 ? (value / total * 100) : 0.0;

      return {
        'name': item['name'],
        'value': value,
        'percentage': percentage,
        'color': item['color'],
      };
    }).toList();
  }

  // Build legend for the pie chart

  // Build holdings table
  Widget _buildHoldingsTable(
      MarketWatchProvider marketWatch, ThemesProvider theme) {
    final shareholdingsData = marketWatch.fundamentalData?.shareholdings;
    if (shareholdingsData == null || shareholdingsData.isEmpty) {
      return Center(
        child: TextWidget.paraText(
          text: 'No holdings data available',
          theme: theme.isDarkMode,
          fw: 0,
          color: theme.isDarkMode
              ? colors.textSecondaryDark
              : colors.textSecondaryLight,
        ),
      );
    }

    // Sort data by date (oldest first)
    final sortedData = List<Shareholdings>.from(shareholdingsData);
    sortedData.sort((a, b) {
      final orderMap = {
        'Jun 24': 1,
        'Sep 24': 2,
        'Dec 24': 3,
        'Mar 25': 4,
        'Jun 25': 5,
      };
      final aOrder = orderMap[a.convDate] ?? 0;
      final bOrder = orderMap[b.convDate] ?? 0;
      return aOrder.compareTo(bOrder); // Ascending order to get oldest first
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HoldingsTable(
          data: sortedData,
          themes: theme,
        ),
      ],
    );
  }
}

// Holdings Table Widget
class HoldingsTable extends StatelessWidget {
  final List<Shareholdings> data;
  final ThemesProvider themes;

  const HoldingsTable({
    super.key,
    required this.data,
    required this.themes,
  });

  String _formatValue(String? value) {
    if (value == null || value.isEmpty) return "0.0";
    try {
      double numValue = double.parse(value);
      return numValue.toStringAsFixed(1);
    } catch (e) {
      return value;
    }
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return "";
    return date; // Keep original format like "Jun 25"
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with years
          _buildHeaderRow(),
          // Data rows with colored circles
          ..._buildMetricRows(data),
          // Legend below table
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      child: Row(
        children: [
          // Empty space for the colored circle column
          Expanded(
            flex: 0,
            child: Container(width: 8), // Same width as the colored circles
          ),
          // Year headers
          ...data
              .map((item) => Expanded(
                    child: TextWidget.custmText(
                      text: _formatDate(item.convDate),
                      fs: 12,
                      theme: themes.isDarkMode,
                      color: themes.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      fw: 0,
                      align: TextAlign.right,
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  List<Widget> _buildMetricRows(List<Shareholdings> sortedData) {
    final metrics = [
      {
        "name": "",
        "getValue": (item) => item.promoters,
        "color": const Color(0xFF7C3AED)
      }, // Modern Purple (Insiders)
      {
        "name": "",
        "getValue": (item) => item.fiiFpi,
        "color": const Color(0xFF2563EB)
      }, // Modern Blue (Institutions)
      {
        "name": "",
        "getValue": (item) => item.dii,
        "color": const Color(0xFF059669)
      }, // Modern Green (Holding Company)
      {
        "name": "",
        "getValue": (item) => item.retailAndOthers,
        "color": const Color(0xFFEA580C)
      }, // Modern Orange (Others)
      {
        "name": "",
        "getValue": (item) => item.mutualFunds,
        "color": const Color(0xFFDC2626)
      }, // Modern Red (Corporation)
    ];

    return metrics
        .map((metric) => Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
              child: Row(
                children: [
                  Expanded(
                    flex: 0,
                    child: Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: metric["color"] as Color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  ...sortedData
                      .map((item) => Expanded(
                            child: TextWidget.custmText(
                              text: _formatValue(
                                  (metric["getValue"] as Function)(item)),
                              fs: 12,
                              theme: themes.isDarkMode,
                              color: themes.isDarkMode
                                  ? colors.textPrimaryDark
                                  : colors.textPrimaryLight,
                              fw: 0,
                              align: TextAlign.right,
                            ),
                          ))
                      .toList(),
                ],
              ),
            ))
        .toList();
  }

  Widget _buildLegend() {
    final legendItems = [
      {"name": "Promoter Holding", "color": const Color(0xFF7C3AED)}, // Modern Purple
      {
        "name": "Foreign Institution",
        "color": const Color(0xFF2563EB)
      }, // Modern Blue
      {
        "name": "Other Domestic Institution",
        "color": const Color(0xFF059669)
      }, // Modern Green
      {"name": "Retail and Others", "color": const Color(0xFFEA580C)}, // Modern Orange
      {
        "name": "Mutual Funds",
        "color": const Color(0xFFDC2626)
      }, // Modern Red
    ];

    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Wrap(
        spacing: 20,
        runSpacing: 12,
        children: legendItems
            .map((item) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: item["color"] as Color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextWidget.custmText(
                      text: item["name"] as String,
                      fs: 10,
                      theme: themes.isDarkMode,
                      color: themes.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      fw: 0,
                    ),
                  ],
                ))
            .toList(),
      ),
    );
  }
}
