// screens/algo_create.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/models/strategy_model.dart';
import 'package:mynt_plus/provider/stocks_provider.dart';
import 'package:mynt_plus/res/res.dart';

import '../../provider/thems.dart';
import '../../res/global_state_text.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Strategy Builder', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildEntrySettings(),
            SizedBox(height: 16),
            _buildExitSettings(),
            SizedBox(height: 16),
            _buildInstrumentSettings(),
            SizedBox(height: 16),
            _buildSquareOffSettings(),
            SizedBox(height: 16),
            _buildLegBuilder(),
            SizedBox(height: 16),
            _buildAddedLegsDisplay(),
            SizedBox(height: 16),
          // ADD THIS: Create Strategy Button
          _buildCreateStrategyButton(), 
          ],
        ),
      ),
    );
  }

  Widget _buildCreateStrategyButton() {
  return Consumer(
    builder: (context, ref, child) {
      final strategy = ref.watch(stocksProvide);
      
      // Only show button if there are legs added
      if (strategy.legs.isEmpty) return Container();
      
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: ElevatedButton(
          onPressed: strategy.isLoading ? null : () => strategy.createStrategy(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: strategy.isLoading 
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Creating Strategy...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : Text(
                'Create Strategy',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
        ),
      );
    },
  );
}


  Widget _buildEntrySettings() {
    final strategy = ref.watch(stocksProvide);
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
            'Entry settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),
          
          // Strategy Type Row
          Row(
            children: [
              Text(
                'Strategy Type',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              Spacer(),
              _buildStrategyTypeButtons(),
            ],
          ),
          
          SizedBox(height: 24),
          
          // Time Settings Row
          Row(
            children: [
              SizedBox(width: 100,
                child: Consumer(
                  builder: (context, ref, child) {
                    return _buildTimeField(
                      'Entry\nTime',
                      strategy.entryTime,
                      (time) => strategy.setEntryTime(time),
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
          Row(
            children: [
              
              SizedBox(width: 100,
                child: Consumer(
                  builder: (context, ref, child) {
                    return _buildTimeField(
                      'Exit\nTime',
                      strategy.exitTime,
                      (time) => strategy.setExitTime(time),
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Checkbox(value: strategy.overallTarget, onChanged: (value) => strategy.toggleOverallTarget(), activeColor: colors.primaryLight),
                    Text('Overall Target', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700])),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Row(
                  children: [
                    Checkbox(value: strategy.overallStoploss, onChanged: (value) => strategy.toggleOverallStoploss(), activeColor: colors.primaryLight),
                    Text('Overall Stoploss', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700])),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(children: [
strategy.overallTarget ? Expanded(child: Container(
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: colors.btnBg),
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextFormField(
              controller: strategy.targetPointsController,
              decoration:InputDecoration(
                              hintText: "Target Points",
                             hintStyle: TextWidget.textStyle(
                                      fontSize: 14,
                                      theme: theme.isDarkMode,
                                     color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                                    ),
                              fillColor: theme.isDarkMode ? colors.searchBgDark : colors.searchBg,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: colors.btnBg),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            onChanged: (value) {
                              strategy.setTargetPoints(int.parse(value));
                            },
            ),
          )) : SizedBox(),
          SizedBox(width: 16),
          strategy.overallStoploss ?  Expanded(child: Container(
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: colors.btnBg),
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextFormField(
              controller: strategy.stopLossPointsController,
              decoration: InputDecoration(
                              hintText: "Stop Loss Points",
                             hintStyle: TextWidget.textStyle(
                                      fontSize: 14,
                                      theme: theme.isDarkMode,
                                     color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                                    ),
                              fillColor: theme.isDarkMode ? colors.searchBgDark : colors.searchBg,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: colors.btnBg),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),

                            onChanged: (value) {
                              strategy.setStopLossPoints(int.parse(value));
                            },
            ),
          )) : SizedBox(),

          ],),

         
        ],
      ),
      );
  }

  Widget _buildStrategyTypeButtons() {
    return Consumer(
      builder: (context, ref, child) {
        final strategy = ref.watch(stocksProvide);
        return Row(
          children: [
            _buildToggleButton('Intraday', strategy.strategyType == 'Intraday', () {
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

  Widget _buildTimeField(String label, TimeOfDay time, Function(TimeOfDay) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
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
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Text(
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 14),
                ),
                Spacer(),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstrumentSettings() {
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
            'Instrument settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),
          
          // Index Dropdown Row
          Row(
            children: [
              Text(
                'Index',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              Spacer(),
              Consumer(
                builder: (context, ref, child) {
                  final strategy = ref.watch(stocksProvide);
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: strategy.selectedIndex,
                        items: ['NIFTY', 'BANKNIFTY', 'SENSEX'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
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
          
          SizedBox(height: 20),
          
          // Underlying From Row
          Row(
            children: [
              Row(
                children: [
                  Text(
                    'Underlying from',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[500]),
                ],
              ),
              Spacer(),
              Consumer(
                builder: (context, ref, child) {
                  final strategy = ref.watch(stocksProvide);
                  return Row(
                    children: [
                      _buildToggleButton('Cash', strategy.selectedUnderlying == 'Cash', () {
                        strategy.setSelectedUnderlying('Cash');
                      }),
                      SizedBox(width: 4),
                      _buildToggleButton('Futures', strategy.selectedUnderlying == 'Futures', () {
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
      child: Row(
        children: [
          Row(
            children: [
              Text(
                'Square Off',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
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
                  _buildToggleButton('Partial', strategy.selectedSquareOff == 'Partial', () {
                    strategy.setSelectedSquareOff('Partial');
                  }),
                  SizedBox(width: 4),
                  _buildToggleButton('Complete', strategy.selectedSquareOff == 'Complete', () {
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
        return Container(
          width: double.infinity,
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
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Leg Builder',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.info_outline, size: 16, color: Colors.grey[500]),
                      ],
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () => strategy.toggleLegBuilderCollapsed(),
                      child: Text(
                        strategy.isLegBuilderCollapsed ? 'Expand' : 'Collapse',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              if (!strategy.isLegBuilderCollapsed) ...[
                Divider(height: 1, color: Colors.grey[200]),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // First Row
                      Row(
                        children: [
                          Expanded(child: _buildLegBuilderField('Select segments', _buildSegmentButtons())),
                          SizedBox(width: 16),
                          Expanded(child: _buildLegBuilderField('Total Qty', _buildTotalLotField())),
                          SizedBox(width: 16),
                          Expanded(child: _buildLegBuilderField('Position', _buildPositionButtons())),
                        ],
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Second Row
                      Row(
                        children: [
                          Expanded(child: _buildLegBuilderField('Option Type', _buildOptionTypeButtons())),
                          SizedBox(width: 16),
                          Expanded(child: _buildLegBuilderField('Expiry', _buildExpiryDropdown())),
                          SizedBox(width: 16),
                          Expanded(child: _buildLegBuilderField('Select Strike Criteria', _buildStrikeCriteriaDropdown())),
                        ],
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Third Row
                      Row(
                        children: [
                          Expanded(child: _buildLegBuilderField('Strike Type', _buildStrikeTypeDropdown())),
                          Expanded(flex: 2, child: Container()),
                        ],
                      ),
                      
                      SizedBox(height: 30),
                      
                      // Add Leg Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _addLeg(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text(
                            'Add Leg',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 8),
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
              child: _buildToggleButton('Futures', strategy.selectedSegment == 'Futures', () {
                strategy.setSelectedSegment('Futures');
              }),
            ),
            SizedBox(width: 4),
            Expanded(
              child: _buildToggleButton('Options', strategy.selectedSegment == 'Options', () {
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
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(strategy.totalQty.toString()),
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
              child: _buildToggleButton('Buy', strategy.selectedPosition == 'Buy', () {
                strategy.setSelectedPosition('Buy');
              }),
            ),
            SizedBox(width: 4),
            Expanded(
              child: _buildToggleButton('Sell', strategy.selectedPosition == 'Sell', () {
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
              child: _buildToggleButton('Call', strategy.selectedOptionType == 'Call', () {
                strategy.setSelectedOptionType('Call');
              }),
            ),
            SizedBox(width: 4),
            Expanded(
              child: _buildToggleButton('Put', strategy.selectedOptionType == 'Put', () {
                strategy.setSelectedOptionType('Put');
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpiryDropdown() {
    return Consumer(
      builder: (context, ref, child) {
        final strategy = ref.watch(stocksProvide);
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: strategy.selectedExpiry,
              isExpanded: true,
              items: ['Weekly', 'Monthly'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(fontSize: 14)),
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
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: strategy.selectedStrikeCriteria,
              isExpanded: true,
              items: ['Strike Type', 'Premium Based', 'Strike Based'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(fontSize: 14)),
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
    return Consumer(
      builder: (context, ref, child) {
        final strategy = ref.watch(stocksProvide);
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
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
                  child: Text(value, style: TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (value) => strategy.setSelectedStrikeType(value!),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddedLegsDisplay() {
    return Consumer(
      builder: (context, ref, child) {
        final strategy = ref.watch(stocksProvide);
        // final legs = strategy.legs;

        if (strategy.legs.isEmpty) return Container();
        
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
                'Added Legs (${strategy.legs.length})',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 16),
              ...strategy.legs.asMap().entries.map((entry) {
                int index = entry.key;
                StrategyLeg leg = entry.value;
                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey!),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${leg.action} ${leg.optionType} ${leg.strike}',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Lot: ${leg.quantity}, Expiry: ${leg.expiry}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[800] : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.blue! : Colors.grey!,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 14,
            fontWeight: FontWeight.w500,
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
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Leg added successfully!')),
    );
  }

  void _removeLeg(int index) {
    final strategy = ref.watch(stocksProvide);
    strategy.removeLeg(index);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Leg removed successfully!')),
    );
  }
}
