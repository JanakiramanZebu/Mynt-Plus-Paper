import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../provider/order_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';

class OrderbooGTTkFilterBottomSheet extends ConsumerStatefulWidget {
  const OrderbooGTTkFilterBottomSheet({super.key});

  @override
  ConsumerState<OrderbooGTTkFilterBottomSheet> createState() => _OrderbooGTTkFilterBottomSheetState();
}

class _OrderbooGTTkFilterBottomSheetState extends ConsumerState<OrderbooGTTkFilterBottomSheet> {
  // Local state for filter selection
  String selectedStatus = "All";
  
  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget.titleText(text: "Filter",theme: false,color: theme.isDarkMode ? Colors.white : Colors.black,fw: 1),
              InkWell(
                onTap: () => Navigator.pop(context),
                child: SvgPicture.asset(
                  assets.removeIcon,
                  width: 18,
                  color: theme.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextWidget.subText(text: "By Status",theme: false,color: theme.isDarkMode ? Colors.white : Colors.black,fw: 0),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip("All", theme),
              _buildFilterChip("Active", theme),
              _buildFilterChip("Triggered", theme),
              _buildFilterChip("Cancelled", theme),
              _buildFilterChip("Expired", theme),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      selectedStatus = "All";
                    });
                    Navigator.pop(context, selectedStatus);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.isDarkMode ? Colors.white : Colors.black),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: TextWidget.titleText(text: "Reset",theme: false,color: theme.isDarkMode ? Colors.white : Colors.black,fw: 0),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Pass the selected filter back to the caller
                    Navigator.pop(context, selectedStatus);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.isDarkMode ? Colors.white : Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: TextWidget.titleText(text: "Apply",theme: false,color: theme.isDarkMode ? Colors.white : Colors.black,fw: 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(String label, ThemesProvider theme) {
    final isSelected = selectedStatus == label;
    
    return FilterChip(
      label: TextWidget.titleText(text: label,theme: false,color:isSelected
            ? (theme.isDarkMode ? Colors.black : Colors.white)
            : (theme.isDarkMode ? Colors.white : Colors.black),fw:isSelected ? 1 : 00),

      selected: isSelected,
      selectedColor: theme.isDarkMode ? Colors.white : Colors.black,
      backgroundColor: theme.isDarkMode ? Colors.grey[800] : Colors.grey[200],
      checkmarkColor: theme.isDarkMode ? Colors.black : Colors.white,
      onSelected: (selected) {
        setState(() {
          selectedStatus = label;
        });
      },
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
