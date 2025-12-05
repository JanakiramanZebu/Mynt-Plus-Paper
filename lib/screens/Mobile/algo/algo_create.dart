// screens/algo_create.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/models/strategy_model.dart';
import 'package:mynt_plus/provider/stocks_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';

import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';

class AlgoCreate extends ConsumerStatefulWidget {
  const AlgoCreate({super.key});

  @override
  ConsumerState<AlgoCreate> createState() => _AlgoCreateState();
}

class _AlgoCreateState extends ConsumerState<AlgoCreate> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 48,
          titleSpacing: 0,
          centerTitle: false,
          leading: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              customBorder: const CircleBorder(),
              splashColor: theme.isDarkMode
                  ? colors.splashColorDark
                  : colors.splashColorLight,
              highlightColor: theme.isDarkMode
                  ? colors.highlightDark
                  : colors.highlightLight,
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 44, // Increased touch area
                height: 44,
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_back_ios_outlined,
                  size: 18,
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                ),
              ),
            ),
          ),
          elevation: 0.2,
          title: TextWidget.titleText(
              text: "Algo Builder",
              textOverflow: TextOverflow.ellipsis,
              theme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              fw: 1),
        ),
        body: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildEntrySettings(),
              SizedBox(height: 16),
              // _buildExitSettings(),
              // SizedBox(height: 16),
              _buildInstrumentSettings(),
              // SizedBox(height: 10),
              _buildSquareOffSettings(),
              // SizedBox(height: 16),
              _buildLegBuilder(),
              SizedBox(height: 16),
              _buildAddedLegsDisplay(),
              SizedBox(height: 16),
              // ADD THIS: Create Strategy Button
              _buildCreateStrategyButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateStrategyButton() {
    return Consumer(
      builder: (context, ref, child) {
        final strategy = ref.watch(stocksProvide);
        final theme = ref.watch(themeProvider);
        // Only show button if there are legs added
        if (strategy.legs.isEmpty) return Container();

        return Container(
          width: double.infinity,
          height: 45,
          // padding: EdgeInsets.symmetric(horizontal: 20),
          child: OutlinedButton(
            onPressed:
                strategy.isLoading ? null : () => strategy.createStrategy(),
            style: OutlinedButton.styleFrom(
              backgroundColor:
                  theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
              // padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: strategy.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : TextWidget.subText(
                    text: 'Create Strategy',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.colorBlack
                        : colors.colorWhite,
                    fw: 2,
                  ),
          ),
        );
      },
    );
  }

  Widget _buildEntrySettings() {
    final strategy = ref.watch(stocksProvide);
    final theme = ref.watch(themeProvider);
    return SizedBox(
      width: double.infinity,
      // padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      // decoration: BoxDecoration(
      //   color: theme.isDarkMode ? colors.searchBgDark : colors.searchBg,
      //   borderRadius: BorderRadius.circular(5),
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget.subText(
            text: 'Entry / Exit Settings',
            theme: theme.isDarkMode,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            fw: 0,
          ),
          SizedBox(height: 16),

          // Strategy Type Row
          Row(
            children: [
              TextWidget.subText(
                text: 'Strategy Type',
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 3,
              ),
              Spacer(),
              _buildStrategyTypeButtons(),
            ],
          ),

          SizedBox(height: 24),

          // Time Settings Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 100,
                child: Consumer(
                  builder: (context, ref, child) {
                    return _buildTimeField(
                      'Entry Time',
                      strategy.entryTime,
                      (time) => strategy.setEntryTime(time),
                    );
                  },
                ),
              ),
              SizedBox(
                width: 100,
                child: Consumer(
                  builder: (context, ref, child) {
                    return _buildTimeField(
                      'Exit Time',
                      strategy.exitTime,
                      (time) => strategy.setExitTime(time),
                    );
                  },
                ),
              ),
              // SizedBox(width: 40),
              // Expanded(
              //   child: Consumer(
              //     builder: (context, ref, child) {
              //       return _buildTimeField(
              //         'Exit\nTime',
              //         strategy.exitTime,
              //         (time) => strategy.setExitTime(time),
              //       );
              //     },
              //   ),
              // ),
            ],
          ),

          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior
                          .translucent, // Improves touch detection
                      onTap: () {
                        strategy.toggleOverallTarget();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextWidget.subText(
                              text: 'Overall Target',
                              theme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                              fw: 3,
                            ),
                            SizedBox(width: 10),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                              width: 40,
                              height: 20,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                color: strategy.overallTarget
                                    ? colors.primaryLight.withOpacity(0.25)
                                    : (theme.isDarkMode
                                        ? Colors.grey[700]
                                        : Colors.grey[300]),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: AnimatedAlign(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut,
                                alignment: strategy.overallTarget
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  width: 15,
                                  height: 15,
                                  decoration: BoxDecoration(
                                    color: strategy.overallTarget
                                        ? colors.primaryLight
                                        : Colors.grey[500],
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.25),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        strategy.toggleOverallStoploss();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextWidget.subText(
                              text: 'Overall Stoploss',
                              theme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                              fw: 3,
                            ),
                            SizedBox(width: 10),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                              width: 40,
                              height: 22,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                color: strategy.overallStoploss
                                    ? colors.primaryLight.withOpacity(0.25)
                                    : (theme.isDarkMode
                                        ? Colors.grey[700]
                                        : Colors.grey[300]),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: AnimatedAlign(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut,
                                alignment: strategy.overallStoploss
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  width: 15,
                                  height: 15,
                                  decoration: BoxDecoration(
                                    color: strategy.overallStoploss
                                        ? colors.primaryLight
                                        : Colors.grey[500],
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.25),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              strategy.overallTarget
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width * 0.44,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: colors.btnBg),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: TextFormField(
                          controller: strategy.targetPointsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Target Amount",
                            hintStyle: TextWidget.textStyle(
                              fontSize: 12,
                              theme: theme.isDarkMode,
                              color: (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight).withOpacity(0.4),
                              fw: 0,
                            ),
                            fillColor: theme.isDarkMode
                                ? colors.searchBgDark
                                : colors.searchBg,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: theme.isDarkMode
                                      ? colors.dividerDark
                                      : colors.dividerLight),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: theme.isDarkMode
                                      ? colors.dividerDark
                                      : colors.dividerLight),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: theme.isDarkMode
                                      ? colors.dividerDark
                                      : colors.dividerLight),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onChanged: (value) {
                            strategy.setTargetPoints(int.parse(value));
                          },
                        ),
                      ),
                    )
                  : SizedBox(),
              SizedBox(
                  width: strategy.overallTarget && strategy.overallStoploss
                      ? 16
                      : 0),
              strategy.overallStoploss
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width * 0.44,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: colors.btnBg),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: TextFormField(
                          controller: strategy.stopLossPointsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Stoploss Amount",
                            hintStyle: TextWidget.textStyle(
                              fontSize: 12,
                              theme: theme.isDarkMode,
                              color: (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight).withOpacity(0.4),
                              fw: 0,
                            ),
                            fillColor: theme.isDarkMode
                                ? colors.searchBgDark
                                : colors.searchBg,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: theme.isDarkMode
                                      ? colors.dividerDark
                                      : colors.dividerLight),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: theme.isDarkMode
                                      ? colors.dividerDark
                                      : colors.dividerLight),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: theme.isDarkMode
                                      ? colors.dividerDark
                                      : colors.dividerLight),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onChanged: (value) {
                            strategy.setStopLossPoints(int.parse(value));
                          },
                        ),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExitSettings() {
    final strategy = ref.watch(stocksProvide);
    final theme = ref.watch(themeProvider);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Exit settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          // SizedBox(height: 20),

          // Strategy Type Row
          // Row(
          //   children: [
          //     _buildStrategyTypeButtons(),
          //   ],
          // ),

          SizedBox(height: 24),

          // Time Settings Row
        ],
      ),
    );
  }

  Widget _buildStrategyTypeButtons() {
    final theme = ref.watch(themeProvider);
    return Consumer(
      builder: (context, ref, child) {
        final strategy = ref.watch(stocksProvide);
        return Row(
          children: [
            _buildToggleButton('Intraday', strategy.strategyType == 'Intraday',
                () {
              strategy.setStrategyType('Intraday');
            }),
            // SizedBox(width: 4),
            // _buildToggleButton('BTST', strategy.strategyType == 'BTST', () {
            //   strategy.setStrategyType('BTST');
            // }),
            // SizedBox(width: 4),
            // _buildToggleButton('Positional', strategy.strategyType == 'Positional', () {
            //   strategy.setStrategyType('Positional');
            // }),
          ],
        );
      },
    );
  }

  Widget _buildTimeField(
      String label, TimeOfDay time, Function(TimeOfDay) onChanged) {
    final theme = ref.watch(themeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget.subText(
          text: label,
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textSecondaryDark
              : colors.textSecondaryLight,
          fw: 3,
        ),
        SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: time,
            );
            if (picked != null) {
              onChanged(picked);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                  color: theme.isDarkMode
                      ? colors.dividerDark
                      : colors.dividerLight),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                TextWidget.paraText(
                  text:
                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  fw: 3,
                ),
                Spacer(),
                Icon(Icons.access_time, size: 16, color: colors.iconColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstrumentSettings() {
    final theme = ref.watch(themeProvider);
    return SizedBox(
      width: double.infinity,
      // padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      // decoration: BoxDecoration(
      //   color: theme.isDarkMode ? colors.searchBgDark : colors.searchBg,
      //   borderRadius: BorderRadius.circular(5),
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget.subText(
            text: 'Instrument settings',
            theme: theme.isDarkMode,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            fw: 0,
          ),
          SizedBox(height: 16),

          // Index Dropdown Row
          Row(
            children: [
              TextWidget.subText(
                text: 'Index',
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
                fw: 3,
              ),
              Spacer(),
              Consumer(
                builder: (context, ref, child) {
                  final strategy = ref.watch(stocksProvide);
                  return Container(
                    height: 35,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: theme.isDarkMode
                              ? colors.dividerDark
                              : colors.dividerLight),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: strategy.selectedIndex,
                        items: ['NIFTY', 'BANKNIFTY', 'SENSEX']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: TextWidget.paraText(
                              text: value,
                              theme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                              fw: 0,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) => strategy.setSelectedIndex(value!),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          SizedBox(height: 16),

          // Underlying From Row
          Row(
            children: [
              Row(
                children: [
                  TextWidget.subText(
                    text: 'Underlying from',
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    fw: 3,
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.info_outline, size: 16, color: colors.iconColor),
                ],
              ),
              Spacer(),
              Consumer(
                builder: (context, ref, child) {
                  final strategy = ref.watch(stocksProvide);
                  return Row(
                    children: [
                      _buildToggleButton(
                          'Cash', strategy.selectedUnderlying == 'Cash', () {
                        strategy.setSelectedUnderlying('Cash');
                      }),
                      SizedBox(width: 4),
                      _buildToggleButton(
                          'Futures', strategy.selectedUnderlying == 'Futures',
                          () {
                        strategy.setSelectedUnderlying('Futures');
                      }),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSquareOffSettings() {
    final theme = ref.watch(themeProvider);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Row(
            children: [
              TextWidget.subText(
                text: 'Square Off',
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
                fw: 3,
              ),
              SizedBox(width: 8),
              Icon(Icons.info_outline, size: 16, color: Colors.grey),
            ],
          ),
          Spacer(),
          Consumer(
            builder: (context, ref, child) {
              final strategy = ref.watch(stocksProvide);
              return Row(
                children: [
                  _buildToggleButton(
                      'Partial', strategy.selectedSquareOff == 'Partial', () {
                    strategy.setSelectedSquareOff('Partial');
                  }),
                  SizedBox(width: 4),
                  _buildToggleButton(
                      'Complete', strategy.selectedSquareOff == 'Complete', () {
                    strategy.setSelectedSquareOff('Complete');
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final strategy = ref.watch(stocksProvide);
        final theme = ref.watch(themeProvider);
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: Row(
                  children: [
                    Row(
                      children: [
                        TextWidget.subText(
                          text: 'Leg Builder',
                          theme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                          fw: 3,
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.info_outline,
                            size: 16, color: colors.iconColor),
                      ],
                    ),
                    Spacer(),
                    Material(
                      color: Colors.transparent,
                      shape: const RoundedRectangleBorder(),
                      child: InkWell(
                        customBorder: const RoundedRectangleBorder(),
                        splashColor: theme.isDarkMode
                            ? colors.splashColorDark
                            : colors.splashColorLight,
                        highlightColor: theme.isDarkMode
                            ? colors.highlightDark
                            : colors.highlightLight,
                        onTap: () => strategy.toggleLegBuilderCollapsed(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: TextWidget.subText(
                            text: strategy.isLegBuilderCollapsed
                                ? 'Expand'
                                : 'Collapse',
                            theme: theme.isDarkMode,
                            color: colors.primaryLight,
                            fw: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              if (!strategy.isLegBuilderCollapsed) ...[
                Divider(
                    height: 1,
                    color: theme.isDarkMode
                        ? colors.dividerDark
                        : colors.dividerLight),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: _buildLegBuilderField(
                                  'Select segments', _buildSegmentButtons())),
                          SizedBox(width: 16),
                          Expanded(
                              child: _buildLegBuilderField(
                                  'Position', _buildPositionButtons())),
                        ],
                      ),

                      SizedBox(height: 16),
                      _buildLegBuilderField('Total Qty',
                          SizedBox(width: 100, child: _buildTotalLotField())),
                      SizedBox(height: 16),

                      // Second Row
                      Row(
                        children: [
                          Expanded(
                              child: _buildLegBuilderField(
                                  'Option Type', _buildOptionTypeButtons())),
                          SizedBox(width: 16),
                          Expanded(
                              child: _buildLegBuilderField(
                                  'Expiry', _buildExpiryDropdown())),
                        ],
                      ),

                      SizedBox(height: 20),

                      // Third Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildLegBuilderField(
                                'Select Strike Criteria',
                                _buildStrikeCriteriaDropdown()),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                              child: _buildLegBuilderField(
                                  strategy.selectedStrikeCriteria ==
                                          'Premium Based'
                                      ? 'Premium Price'
                                      : 'Strike Type',
                                  _buildStrikeTypeDropdown())),
                          // Expanded(flex: 2, child: Container()),
                        ],
                      ),

                      SizedBox(height: 30),

                      // Add Leg Button
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: OutlinedButton(
                          onPressed: () => _addLeg(),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: theme.isDarkMode
                                ? colors.primaryDark
                                : colors.primaryLight,
                            // padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: TextWidget.subText(
                            text: 'Add Leg',
                            theme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? colors.colorBlack
                                : colors.colorWhite,
                            fw: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegBuilderField(String label, Widget child) {
    final theme = ref.watch(themeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget.subText(
          text: label,
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textSecondaryDark
              : colors.textSecondaryLight,
          fw: 0,
        ),
        SizedBox(height: 10),
        child,
      ],
    );
  }

  Widget _buildSegmentButtons() {
    return Consumer(
      builder: (context, ref, child) {
        final strategy = ref.watch(stocksProvide);
        return Row(
          children: [
            Expanded(
              child: _buildToggleButton(
                  'Futures', strategy.selectedSegment == 'Futures', () {
                strategy.setSelectedSegment('Futures');
              }),
            ),
            SizedBox(width: 4),
            Expanded(
              child: _buildToggleButton(
                  'Options', strategy.selectedSegment == 'Options', () {
                strategy.setSelectedSegment('Options');
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTotalLotField() {
    return Consumer(
      builder: (context, ref, child) {
        final strategy = ref.watch(stocksProvide);
        final theme = ref.watch(themeProvider);
        return Container(
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextFormField(
            controller: strategy.totalQtyController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Qty",
              hintStyle: TextWidget.textStyle(
                fontSize: 12,
                theme: theme.isDarkMode,
                color: (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight).withOpacity(0.4),
                fw: 0,
              ),
              fillColor:
                  theme.isDarkMode ? colors.searchBgDark : colors.searchBg,
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                    color: theme.isDarkMode
                        ? colors.dividerDark
                        : colors.dividerLight),
                borderRadius: BorderRadius.circular(5),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: theme.isDarkMode
                        ? colors.dividerDark
                        : colors.dividerLight),
                borderRadius: BorderRadius.circular(5),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: theme.isDarkMode
                        ? colors.dividerDark
                        : colors.dividerLight),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            onChanged: (value) {
              strategy.setTotalQty(value);
            },
          ),
        );
      },
    );
  }

  Widget _buildPositionButtons() {
    return Consumer(
      builder: (context, ref, child) {
        final strategy = ref.watch(stocksProvide);
        return Row(
          children: [
            Expanded(
              child: _buildToggleButton(
                  'Buy', strategy.selectedPosition == 'Buy', () {
                strategy.setSelectedPosition('Buy');
              }),
            ),
            SizedBox(width: 4),
            Expanded(
              child: _buildToggleButton(
                  'Sell', strategy.selectedPosition == 'Sell', () {
                strategy.setSelectedPosition('Sell');
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOptionTypeButtons() {
    return Consumer(
      builder: (context, ref, child) {
        final strategy = ref.watch(stocksProvide);
        return Row(
          children: [
            Expanded(
              child: _buildToggleButton(
                  'Call', strategy.selectedOptionType == 'Call', () {
                strategy.setSelectedOptionType('Call');
              }),
            ),
            SizedBox(width: 4),
            Expanded(
              child: _buildToggleButton(
                  'Put', strategy.selectedOptionType == 'Put', () {
                strategy.setSelectedOptionType('Put');
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpiryDropdown() {
    final theme = ref.watch(themeProvider);
    return Consumer(
      builder: (context, ref, child) {
        final strategy = ref.watch(stocksProvide);
        return Container(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
                color: theme.isDarkMode
                    ? colors.dividerDark
                    : colors.dividerLight),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: strategy.selectedExpiry,
              isExpanded: true,
              items: ['Weekly', 'Monthly'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: TextWidget.paraText(
                    text: value,
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    fw: 0,
                  ),
                );
              }).toList(),
              onChanged: (value) => strategy.setSelectedExpiry(value!),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStrikeCriteriaDropdown() {
    return Consumer(
      builder: (context, ref, child) {
        final strategy = ref.watch(stocksProvide);
        final theme = ref.watch(themeProvider);
        return Container(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
                color: theme.isDarkMode
                    ? colors.dividerDark
                    : colors.dividerLight),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: strategy.selectedStrikeCriteria,
              isExpanded: true,
              items: ['Strike Type', 'Premium Based', 'Strike Based']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: TextWidget.paraText(
                    text: value,
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    fw: 0,
                  ),
                );
              }).toList(),
              onChanged: (value) => strategy.setSelectedStrikeCriteria(value!),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStrikeTypeDropdown() {
    final theme = ref.watch(themeProvider);
    return Consumer(
      builder: (context, ref, child) {
        final strategy = ref.watch(stocksProvide);
        return strategy.selectedStrikeCriteria != 'Premium Based'
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: strategy.selectedStrikeType,
                    isExpanded: true,
                    items: ['ATM', 'ITM', 'OTM'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: TextWidget.paraText(
                          text: value,
                          theme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                          fw: 0,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        strategy.setSelectedStrikeType(value!),
                  ),
                ),
              )
            : Container(
                // padding: EdgeInsets.symmetric(horizontal: 5),
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextFormField(
                  controller: strategy.targetPointsController,
                  decoration: InputDecoration(
                    hintText: "Price",
                    hintStyle: TextWidget.textStyle(
                      fontSize: 14,
                      theme: theme.isDarkMode,
                      color:(theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight).withOpacity(0.4),
                      fw: 0,
                    ),
                    fillColor: theme.isDarkMode
                        ? colors.searchBgDark
                        : colors.searchBg,
                    filled: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: theme.isDarkMode
                              ? colors.dividerDark
                              : colors.dividerLight),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: theme.isDarkMode
                              ? colors.dividerDark
                              : colors.dividerLight),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: theme.isDarkMode
                              ? colors.dividerDark
                              : colors.dividerLight),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onChanged: (value) {
                    strategy.setTargetPoints(int.parse(value));
                  },
                ),
              );
      },
    );
  }

  Widget _buildAddedLegsDisplay() {
    return Consumer(
      builder: (context, ref, child) {
        final strategy = ref.watch(stocksProvide);
        final theme = ref.watch(themeProvider);
        // final legs = strategy.legs;

        if (strategy.legs.isEmpty) return Container();

        return Container(
          width: double.infinity,
          // padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget.subText(
                text: 'Added Legs (${strategy.legs.length})',
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 0,
              ),
              SizedBox(height: 16),
              ...strategy.legs.asMap().entries.map((entry) {
                int index = entry.key;
                StrategyLeg leg = entry.value;
                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.isDarkMode
                        ? colors.searchBgDark
                        : colors.searchBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: theme.isDarkMode
                            ? colors.dividerDark
                            : colors.dividerLight),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget.subText(
                              text:
                                  '${leg.action} ${leg.optionType} ${leg.strike}',
                              theme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? colors.textPrimaryDark
                                  : colors.textPrimaryLight,
                              fw: 0,
                            ),
                            TextWidget.paraText(
                              text:
                                  'Lot: ${leg.quantity}, Expiry: ${leg.expiry}',
                              theme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                              fw: 0,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete,
                            color: theme.isDarkMode
                                ? colors.lossDark
                                : colors.lossLight),
                        onPressed: () => _removeLeg(index),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggleButton(String text, bool isSelected, VoidCallback onTap) {
    final theme = ref.watch(themeProvider);
    return Container(
      // height: 35,
      decoration: BoxDecoration(
        color: isSelected
            ? theme.isDarkMode
                ? colors.searchBgDark
                : colors.searchBg
            : colors.colorWhite,
        border: Border.all(
          color: isSelected ? colors.btnOutlinedBorder : colors.colorWhite,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          onTap: onTap,
          splashColor: theme.isDarkMode
              ? colors.splashColorDark
              : colors.splashColorLight,
          highlightColor:
              theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
            child: TextWidget.subText(
              text: text,
              theme: theme.isDarkMode,
              color: isSelected
                  ? theme.isDarkMode
                      ? colors.primaryDark
                      : colors.primaryLight
                  : theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
              fw: isSelected ? 1 : 3,
              align: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  void _addLeg() {
    final strategy = ref.watch(stocksProvide);
    final leg = {
      'segment': strategy.selectedSegment,
      'totalQty': strategy.totalQty,
      'position': strategy.selectedPosition,
      'optionType': strategy.selectedOptionType,
      'expiry': strategy.selectedExpiry,
      'strikeCriteria': strategy.selectedStrikeCriteria,
      'strikeType': strategy.selectedStrikeType,
    };

    final currentLegs = strategy.legs;
    strategy.addLeg();

    successMessage(context, 'Leg added successfully!');
  }

  void _removeLeg(int index) {
    final strategy = ref.watch(stocksProvide);
    strategy.removeLeg(index);
    successMessage(context, 'Leg removed successfully!');
  }
}
