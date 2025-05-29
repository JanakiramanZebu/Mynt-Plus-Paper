import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../provider/order_provider.dart';
import '../../provider/thems.dart';
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
              Text(
                "Filter", 
                style: TextStyle(
                  color: theme.isDarkMode ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600
                )
              ),
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
          Text(
            "By Status",
            style: TextStyle(
              color: theme.isDarkMode ? Colors.white : Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500
            ),
          ),
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
                  child: Text(
                    "Reset",
                    style: TextStyle(
                      color: theme.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
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
                  child: Text(
                    "Apply",
                    style: TextStyle(
                      color: theme.isDarkMode ? Colors.black : Colors.white,
                    ),
                  ),
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
      label: Text(
        label,
        style: TextStyle(
          color: isSelected 
            ? (theme.isDarkMode ? Colors.black : Colors.white)
            : (theme.isDarkMode ? Colors.white : Colors.black),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
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
