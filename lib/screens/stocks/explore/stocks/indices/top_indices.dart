import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../provider/index_list_provider.dart';
import '../../../../../provider/stocks_provider.dart';
import '../../../../../routes/route_names.dart';
import 'top_indices_list_card.dart';

class TopIndices extends StatefulWidget {
  const TopIndices({super.key});

  @override
  State<TopIndices> createState() => _TopIndicesState();
}

class _TopIndicesState extends State<TopIndices> {
  final ScrollController _scrollController = ScrollController();
  int _currentDotIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateDotIndex);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateDotIndex);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateDotIndex() {
    // Calculate the currently visible item index
    double itemHeight = 100.0; // Update this to match your item height
    int newIndex = (_scrollController.offset / itemHeight).floor();

    if (newIndex != _currentDotIndex) {
      setState(() {
        _currentDotIndex = newIndex;
      });
    }
  }

  // Function to scroll to a specific index
  void _scrollToIndex(int index) {
    double itemHeight = 100.0; // Update this to match your item height
    double offset = index * itemHeight;
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(context) {
    return Consumer(builder: (context, watch, child) {
      final indices = watch(indexListProvider);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Top Index",
                      style: GoogleFonts.inter(
                          textStyle: textStyle(
                              const Color(0xff000000), 16, FontWeight.w600))),
                  TextButton(
                      onPressed: () async {
                        await context.read(indexListProvider).fetchAllIndex();
                        await context.read(stocksProvide).getGlobalIndices();
                        Navigator.pushNamed(context, Routes.allIndex);
                      },
                      child: Text('See all',
                          style: GoogleFonts.inter(
                              color: const Color(0xff0037B7),
                              fontSize: 14,
                              fontWeight: FontWeight.w600)))
                ]),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.only(left: 14),
            height: 50,
            child: ListView.separated(
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(width: 9);
              },
              controller: _scrollController,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: indices.defTopIndex!.indValues!.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () async {
                    // Handle item tap
                  },
                  child: TopIndicesListCard(
                    indicesData: indices.defTopIndex!.indValues![index],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16), // Adjust the height as needed
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                indices.defTopIndex!.indValues!.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => setState(() {
                  _currentDotIndex = entry.key;
                  _scrollToIndex(entry.key); // Scroll to the selected index
                }),
                child: Container(
                  width: _currentDotIndex == entry.key ? 15.0 : 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: _currentDotIndex == entry.key
                        ? Colors.black
                        : Colors.grey.shade400,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
    });
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize);
  }
}
