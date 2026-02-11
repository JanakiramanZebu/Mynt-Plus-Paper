import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      backgroundColor: theme.isDarkMode ? MyntColors.backgroundColorDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 600, // Limit width for web/tablet
        ),
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          children: [
            // Header: Search Bar + Close Icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                Expanded(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.isDarkMode
                          ? MyntColors.inputBgDark
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
                              if(value.isEmpty){
                                mfData.commonsearch();
                              }else{
                              mfData.fetchmfCommonsearch(value, context);
                              }
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
                    mfData.commonsearch();
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
                              separatorBuilder: (context, index) => Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: resolveThemeColor(
                                        context,
                                        dark: MyntColors.dividerDark,
                                        light: MyntColors.divider,
                                      ),
                                      width: 0.5,
                                    ),
                                  ),
                                ),
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
      padding: const EdgeInsets.only(left: 16, right: 12, top: 10, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // AMC Logo
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.transparent,
            backgroundImage: NetworkImage(
              "https://v3.mynt.in/mfapi/static/images/mf/$amcCode.png",
            ),
          ),
          const SizedBox(width: 10),

          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.schemeName ?? item.mfsearchnamename ?? "Unknown Fund",
                  style: MyntWebTextStyles.body(
                    context,
                    color: resolveThemeColor(
                      context,
                      dark: MyntColors.textPrimaryDark,
                      light: MyntColors.textPrimary,
                    ),
                    fontWeight: MyntFonts.medium,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.schemeType ?? item.type ?? "Equity",
                  style: MyntWebTextStyles.caption(
                    context,
                    color: resolveThemeColor(
                      context,
                      dark: MyntColors.textSecondaryDark,
                      light: MyntColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Action Icon
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              splashColor: Colors.grey.withValues(alpha: 0.2),
              highlightColor: Colors.grey.withValues(alpha: 0.1),
              onTap: () async {
                final isin = item.iSIN;
                if (isin != null) {
                  await mfData.fetchcommonsearchWadd(
                    isin,
                    isAdded ? "delete" : "add",
                    context,
                    false,
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(7),
                child: SvgPicture.asset(
                  isAdded ? assets.bookmarkIcon : assets.bookmarkedIcon,
                  colorFilter: ColorFilter.mode(
                    isAdded
                        ? resolveThemeColor(
                            context,
                            dark: MyntColors.primaryDark,
                            light: MyntColors.primary,
                          )
                        : resolveThemeColor(
                            context,
                            dark: MyntColors.iconDark,
                            light: MyntColors.icon,
                          ),
                    BlendMode.srcIn,
                  ),
                  height: 18,
                  width: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
