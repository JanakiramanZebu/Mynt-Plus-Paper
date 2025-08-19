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

        return SafeArea(
          child: Stack(
            children: [
              Container(
               decoration: BoxDecoration(
             borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
           color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
           border: Border(
                                    top: BorderSide(
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                              .withOpacity(0.5)
                                          : colors.colorWhite,
                                    ),
                                    left: BorderSide(
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                              .withOpacity(0.5)
                                          : colors.colorWhite,
                                    ),
                                    right: BorderSide(
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                              .withOpacity(0.5)
                                          : colors.colorWhite,
                                    ),
                                  ),
          
           
          ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextWidget.titleText(
                            text: "Contract Note",
                            theme: theme.isDarkMode,
                              color : theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                            fw: 1,
                          ),
                          Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: () async {
                                await Future.delayed(
                                    const Duration(milliseconds: 150));
                                Navigator.pop(context);
                              },
                              borderRadius: BorderRadius.circular(20),
                              splashColor: theme.isDarkMode
                                  ? Colors.white.withOpacity(0.15)
                                  : Colors.black.withOpacity(0.15),
                              highlightColor: theme.isDarkMode
                                  ? Colors.white.withOpacity(0.08)
                                  : Colors.black.withOpacity(0.08),
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 22,
                                  color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: theme.isDarkMode
                          ? colors.darkColorDivider
                          : colors.colorDivider,
                      height: 0,
                    ),
          
                    // Calendar
                    _buildCalendar(context, ledgerprovider, theme),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
          
              // Loading overlay
              if (ledgerprovider.isContractCalendarLoading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalendar(
      BuildContext context, LDProvider ledgerprovider, dynamic theme) {
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: ledgerprovider.selectedContractFilter == filter
                      ? (theme.isDarkMode
                          ? colors.primaryDark
                          : colors.primaryLight)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.isDarkMode
                        ? colors.primaryDark
                        : colors.primaryLight,
                  ),
                ),
                child: TextWidget.subText(
                  text: filter,
                  theme: theme.isDarkMode,
                  color: ledgerprovider.selectedContractFilter == filter
                      ? Colors.white
                      : null,
                  fw: 0,
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
    // Fetch data for the initial month
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onMonthChanged(_month);
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysToDisplay = _buildMonthDays(_month);
    final weeks = _chunkDays(daysToDisplay, 7);

    return Consumer(builder: (context, ref, child) {
      final ledgerprovider = ref.watch(ledgerProvider);
      final theme = ref.watch(themeProvider);
      return SafeArea(
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          elevation: 0,
            color:
                widget.theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Column(
            children: [
              // Month title with left/right arrows
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          color: theme.isDarkMode ? colors.textSecondaryDark : colors.textPrimaryLight,
                          onPressed: _goToPreviousMonth,
                        ),
                        TextWidget.titleText(
                          text: _formatMonthYear(_month),
                          theme: widget.theme.isDarkMode,
                          color: theme.isDarkMode ? colors.textSecondaryDark : colors.textPrimaryLight,
                          fw: 1,
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          color: theme.isDarkMode ? colors.textSecondaryDark : colors.textPrimaryLight,
                          onPressed: _goToNextMonth,
                        ),
                      ],
                    ),

                    // Toggle-like Filter
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children:
                            ledgerprovider.contractFilterOptions.map((filter) {
                          final isSelected =
                              ledgerprovider.selectedContractFilter == filter;
                          // Map display names
                          String displayName = filter == 'CN'
                              ? 'MCX'
                              : (filter == 'Contract' ? 'Combine' : filter);
                          return GestureDetector(
                            onTap: () {
                              ledgerprovider.setContractFilter(filter);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colors.primaryLight
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: TextWidget.paraText(
                                text: displayName,
                                theme: theme.isDarkMode,
                                color: isSelected ? theme.isDarkMode ?  colors.colorWhite : colors.colorWhite : theme.isDarkMode ? colors.textSecondaryDark : colors.textPrimaryLight,
                                fw: 0,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  ],
                ),
              ),
              // Day headers (Mon–Sun)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextWidget.paraText(
                        text: "Mon", color: theme.isDarkMode ? colors.textSecondaryDark : colors.textPrimaryLight, theme: widget.theme.isDarkMode, fw: 1),
                    TextWidget.paraText(
                        text: "Tue", color: theme.isDarkMode ? colors.textSecondaryDark : colors.textPrimaryLight, theme: widget.theme.isDarkMode, fw: 1),
                    TextWidget.paraText(
                        text: "Wed", color: theme.isDarkMode ? colors.textSecondaryDark : colors.textPrimaryLight, theme: widget.theme.isDarkMode, fw: 1),
                    TextWidget.paraText(
                        text: "Thu", color: theme.isDarkMode ? colors.textSecondaryDark : colors.textPrimaryLight, theme: widget.theme.isDarkMode, fw: 1),
                    TextWidget.paraText(
                        text: "Fri", color: theme.isDarkMode ? colors.textSecondaryDark : colors.textPrimaryLight, theme: widget.theme.isDarkMode, fw: 1),
                    TextWidget.paraText(
                        text: "Sat", color: theme.isDarkMode ? colors.textSecondaryDark : colors.textPrimaryLight, theme: widget.theme.isDarkMode, fw: 1),
                    TextWidget.paraText(
                        text: "Sun", color: theme.isDarkMode ? colors.textSecondaryDark : colors.textPrimaryLight, theme: widget.theme.isDarkMode, fw: 1),
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
    });
  }

  Widget _buildDayBox(BuildContext context, DateTime date) {
    double screenWidth = MediaQuery.of(context).size.width;
    final ledgerprovider =
        ProviderScope.containerOf(context, listen: false).read(ledgerProvider);
    final docs = ledgerprovider.contractDocumentDetails[date] ?? [];
    final selectedType = ledgerprovider.selectedContractFilter;
    final DocumentDetail? doc = docs.cast<DocumentDetail?>().firstWhere(
          (d) => d != null && d.docType == selectedType,
          orElse: () => null,
        );
    final hasSelectedType = doc != null;

    // Detect if this day is outside the current month
    final bool isOutsideMonth = date.month != _month.month;

    Color bgColor;
    if (isOutsideMonth) {
      bgColor = Colors.grey.shade200;
    } else if (hasSelectedType) {
      bgColor = colors.primaryLight;
    } else {
      bgColor = const Color(0xffF1F3F8);
    }

    Color textColor = isOutsideMonth
        ? Colors.grey
        : (hasSelectedType ? colors.colorWhite : colors.colorBlack);

    return GestureDetector(
      onTap: (hasSelectedType && !isOutsideMonth)
          ? () {
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
              child: TextWidget.paraText(
                text: date.day.toString(),
                color: textColor,
                theme: widget.theme.isDarkMode,
                fw: 0,
              ),
            ),
            if (hasSelectedType && !isOutsideMonth)
              const Positioned(
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
      final endIndex =
          (i + chunkSize > days.length) ? days.length : (i + chunkSize);
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
