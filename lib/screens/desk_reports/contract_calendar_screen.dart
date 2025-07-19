import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/custom_back_btn.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';

class ContractCalendarScreen extends StatefulWidget {
  const ContractCalendarScreen({super.key});

  @override
  State<ContractCalendarScreen> createState() => _ContractCalendarScreenState();
}

class _ContractCalendarScreenState extends State<ContractCalendarScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch current month documents when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      // Use ref.read instead of context.read
      // This will be handled in the build method
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final ledgerprovider = ref.watch(ledgerProvider);
        final theme = ref.watch(themeProvider);
        
        return Scaffold(
          backgroundColor: theme.isDarkMode ? const Color(0xff1A1A1A) : const Color(0xffF1F3F8),
          appBar: AppBar(
            backgroundColor: theme.isDarkMode ? const Color(0xff1A1A1A) : const Color(0xffF1F3F8),
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: theme.isDarkMode ? Colors.white : Colors.black,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Contract Calendar',
              style: textStyle(
                theme.isDarkMode ? Colors.white : Colors.black,
                18,
                FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  // Filter Toggle
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.isDarkMode ? const Color(0xff3A3A3A) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: ledgerprovider.contractFilterOptions.map((filter) {
                        final isSelected = ledgerprovider.selectedContractFilter == filter;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              ledgerprovider.setContractFilter(filter);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  filter,
                                  style: textStyle(
                                    isSelected ? Colors.white : (theme.isDarkMode ? Colors.white : Colors.black),
                                    14,
                                    FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  // Calendar
                  Expanded(
                    child: _buildCalendar(context, ledgerprovider, theme),
                  ),
                ],
              ),
              
              // Loading overlay
              if (ledgerprovider.isContractCalendarLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalendar(BuildContext context, LDProvider ledgerprovider, dynamic theme) {
    return _ContractCalendar(
      theme: theme,
      documentDates: ledgerprovider.contractDocumentDates,
      selectedFilter: ledgerprovider.selectedContractFilter,
      onMonthChanged: (DateTime newMonth) {
        ledgerprovider.fetchContractDocuments(newMonth.year, newMonth.month);
      },
    );
  }

  Widget _buildFilterToggle(dynamic theme, LDProvider ledgerprovider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (String filter in ledgerprovider.contractFilterOptions)
            GestureDetector(
              onTap: () {
                ledgerprovider.setContractFilter(filter);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: ledgerprovider.selectedContractFilter == filter
                      ? (theme.isDarkMode ? colors.primaryDark : colors.primaryLight)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: ledgerprovider.selectedContractFilter == filter
                        ? Colors.white
                        : (theme.isDarkMode ? colors.primaryDark : colors.primaryLight),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Contract Calendar Widget
class _ContractCalendar extends StatefulWidget {
  final dynamic theme;
  final Map<DateTime, List<String>> documentDates;
  final String selectedFilter;
  final ValueChanged<DateTime> onMonthChanged;

  const _ContractCalendar({
    required this.theme,
    required this.documentDates,
    required this.selectedFilter,
    required this.onMonthChanged,
  });

  @override
  State<_ContractCalendar> createState() => _ContractCalendarState();
}

class _ContractCalendarState extends State<_ContractCalendar> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    _month = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final daysToDisplay = _buildMonthDays(_month);
    final weeks = _chunkDays(daysToDisplay, 7);
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 0,
      color: widget.theme.isDarkMode ? const Color(0xff1E1E1E) : Colors.white,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Month title with left/right arrows
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _goToPreviousMonth,
                  ),
                  Text(
                    _formatMonthYear(_month),
                    style: textStyle(
                      widget.theme.isDarkMode ? Colors.white : Colors.black,
                      16,
                      FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _goToNextMonth,
                  ),
                ],
              ),
            ),
            // Day headers (Mon–Sun)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("Mon", style: textStyle(widget.theme.isDarkMode ? Colors.white : Colors.black, 12, FontWeight.w700)),
                  Text("Tue", style: textStyle(widget.theme.isDarkMode ? Colors.white : Colors.black, 12, FontWeight.w700)),
                  Text("Wed", style: textStyle(widget.theme.isDarkMode ? Colors.white : Colors.black, 12, FontWeight.w700)),
                  Text("Thu", style: textStyle(widget.theme.isDarkMode ? Colors.white : Colors.black, 12, FontWeight.w700)),
                  Text("Fri", style: textStyle(widget.theme.isDarkMode ? Colors.white : Colors.black, 12, FontWeight.w700)),
                  Text("Sat", style: textStyle(widget.theme.isDarkMode ? Colors.white : Colors.black, 12, FontWeight.w700)),
                  Text("Sun", style: textStyle(widget.theme.isDarkMode ? Colors.white : Colors.black, 12, FontWeight.w700)),
                ],
              ),
            ),
            // Calendar grid: rows of 7 days
            for (final week in weeks)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (final day in week) _buildDayBox(context, day),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayBox(BuildContext context, DateTime date) {
    double screenWidth = MediaQuery.of(context).size.width;
    final ledgerprovider = ProviderScope.containerOf(context, listen: false).read(ledgerProvider);
    // Check if date has documents of selected filter type
    final docs = ledgerprovider.contractDocumentDetails[date] ?? [];
    final selectedType = ledgerprovider.selectedContractFilter;
    final DocumentDetail? doc = docs.cast<DocumentDetail?>().firstWhere(
      (d) => d != null && d.docType == selectedType,
      orElse: () => null,
    );
    final hasSelectedType = doc != null;
    
    Color bgColor;
    if (hasSelectedType) {
      bgColor = Colors.blue.withOpacity(0.3); // Highlight color for documents
    } else {
      bgColor = widget.theme.isDarkMode ? const Color(0xff3A3A3A) : const Color(0xffF1F3F8);
    }
    
    return GestureDetector(
      onTap: hasSelectedType
          ? () {
              // Initiate download
              ledgerprovider.pdfdownloadfunction(
                context,
                doc!.recno,
                doc.docFileName,
              );
            }
          : null,
      child: Container(
        width: screenWidth * 0.09,
        height: screenWidth * 0.09,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                date.day.toString(),
                style: textStyle(
                  widget.theme.isDarkMode ? Colors.white : Colors.black,
                  12,
                  FontWeight.w500,
                ),
              ),
            ),
            if (hasSelectedType)
              Positioned(
                top: 2,
                right: 2,
                child: Icon(
                  Icons.download,
                  size: 12,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<DateTime> _buildMonthDays(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    
    final days = <DateTime>[];
    
    // Add days from previous month to fill first week
    final firstWeekday = firstDay.weekday;
    for (int i = firstWeekday - 1; i > 0; i--) {
      days.add(firstDay.subtract(Duration(days: i)));
    }
    
    // Add days of current month
    for (int i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(month.year, month.month, i));
    }
    
    // Add days from next month to fill last week
    final lastWeekday = lastDay.weekday;
    for (int i = 1; i <= 7 - lastWeekday; i++) {
      days.add(lastDay.add(Duration(days: i)));
    }
    
    return days;
  }

  List<List<DateTime>> _chunkDays(List<DateTime> days, int chunkSize) {
    final chunks = <List<DateTime>>[];
    for (int i = 0; i < days.length; i += chunkSize) {
      final endIndex = (i + chunkSize > days.length) ? days.length : (i + chunkSize);
      chunks.add(days.sublist(i, endIndex));
    }
    return chunks;
  }

  String _formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  void _goToPreviousMonth() {
    setState(() {
      _month = DateTime(_month.year, _month.month - 1, 1);
    });
    widget.onMonthChanged(_month);
  }

  void _goToNextMonth() {
    setState(() {
      _month = DateTime(_month.year, _month.month + 1, 1);
    });
    widget.onMonthChanged(_month);
  }
} 