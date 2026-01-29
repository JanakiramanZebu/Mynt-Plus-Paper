import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../res/mynt_web_text_styles.dart';
import '../../../res/mynt_web_color_styles.dart';

class MFSearchPopup extends ConsumerStatefulWidget {
  const MFSearchPopup({super.key});

  @override
  ConsumerState<MFSearchPopup> createState() => _MFSearchPopupState();
}

class _MFSearchPopupState extends ConsumerState<MFSearchPopup> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final mfData = ref.watch(mfProvider);

    return Dialog(
      backgroundColor: theme.isDarkMode ? const Color(0xff1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 600, // Limit width for web/tablet
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header: Search Bar + Close Icon
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.isDarkMode
                          ? MyntColors.searchBgDark
                          : MyntColors.searchBg,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          size: 20,
                          color: theme.isDarkMode
                              ? MyntColors.textSecondaryDark
                              : MyntColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            style: MyntWebTextStyles.body(context),
                            decoration: InputDecoration(
                              hintText: "Search Fund",
                              hintStyle: MyntWebTextStyles.placeholder(context),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (value) {
                              mfData.fetchmfCommonsearch(value, context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.close,
                    color: theme.isDarkMode ? Colors.white70 : Colors.black54,
                    size: 24,
                  ),
                ),
              ],
            ),

            // Content Area
            Expanded(
              child: mfData.bestmfloader == true
                  ? const Center(child: CircularProgressIndicator())
                  : (_searchController.text.isEmpty &&
                          (mfData.mutualFundsearchdata == null ||
                              mfData.mutualFundsearchdata!.isEmpty))
                      ? _buildEmptyState(theme) // "Start Searching" State
                      : (mfData.mutualFundsearchdata == null ||
                              mfData.mutualFundsearchdata!.isEmpty)
                          ? Center(
                              child: const NoDataFound(secondaryEnabled: false))
                          : ListView.separated(
                              padding: const EdgeInsets.only(top: 24),
                              itemCount:
                                  mfData.mutualFundsearchdata?.length ?? 0,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                thickness: 0.5,
                                color: theme.isDarkMode
                                    ? const Color(0xff333333)
                                    : const Color(0xffF0F0F0),
                              ),
                              itemBuilder: (context, index) {
                                final item =
                                    mfData.mutualFundsearchdata![index];
                                return _buildListItem(
                                    context, item, theme, mfData);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemesProvider theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Bull Icon Placeholder (You may want to replace with asset)
        Icon(
          Icons.show_chart, // Placeholder for the bull icon
          size: 64,
          color: theme.isDarkMode ? Colors.grey[700] : Colors.grey[400],
        ),
        const SizedBox(height: 24),
        Text(
          "Start Searching",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Type to search for stocks, indices, or options.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: theme.isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),
        InkWell(
          onTap: () {
            Navigator.pop(context);
            // logic to go to explore if needed?
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
                color: theme.isDarkMode ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(6)),
            child: Text(
              "Explore",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.isDarkMode ? Colors.white : Colors.black87),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildListItem(BuildContext context, dynamic item,
      ThemesProvider theme, dynamic mfData) {
    final amcCode = item.aMCCode ?? "default";
    final isAdded = item.isAdd ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // AMC Logo
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.transparent,
            backgroundImage: NetworkImage(
              "https://v3.mynt.in/mfapi/static/images/mf/$amcCode.png",
            ),
          ),
          const SizedBox(width: 12),

          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.schemeName ?? item.mfsearchnamename ?? "Unknown Fund",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.isDarkMode ? Colors.white : Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.schemeType ?? item.type ?? "Equity",
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        theme.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Action Icon
          const SizedBox(width: 8),
          InkWell(
            onTap: () async {
                final isin = item.iSIN;
                if (isin != null) {
                await mfData.fetchcommonsearchWadd(
                    isin,
                    isAdded ? "delete" : "add",
                    context,
                    false, // isToast
                );
                // setState(() {}); // UI updates via provider usually, but force refresh if needed
                }
            },
            child: isAdded 
            ? Icon(
                Icons.bookmark,
                color: colors.colorBlue, // Assuming this is available in global colors or use generic blue
                size: 24,
              )
            : Icon(
                Icons.bookmark_add_outlined, // Or fa_bookmark style
                 color: theme.isDarkMode ? Colors.white70 : Colors.black54,
                size: 24,
              ),
          ),
        ],
      ),
    );
  }
}
