import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import '../../provider/fund_provider.dart';
import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';

class MFWatchlistScreen extends ConsumerWidget {
  const MFWatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final fund = ref.watch(fundProvider);
    final mfData = ref.watch(mfProvider);

    return Scaffold(
      body: TransparentLoaderScreen(
        isLoading: mfData.bestmfloader ?? false,
        child: mfData.mfWatchlist?.isEmpty ?? true
            ? const Center(child: NoDataFound())
            : Column(
                children: [
                  _buildHeader(theme),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: mfData.mfWatchlist?.length ?? 0,
                      itemBuilder: (BuildContext context, int index) {
                        final item = mfData.mfWatchlist?[index];
                        if (item == null) return const SizedBox.shrink();
                        
                        return _buildListItem(context, item, theme, mfData);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader(ThemesProvider theme) {
    return Container(
      color: theme.isDarkMode ? const Color(0xFF2A2A2A): const Color(0xFFF1F3F8),
      padding: const EdgeInsets.only(left: 12, bottom: 8, top: 8, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'FUNDS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: theme.isDarkMode ? Colors.white: Colors.black,
              letterSpacing: 0.7,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              '3Y RETURNS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: theme.isDarkMode ? Colors.white: Colors.black,
                letterSpacing: 0.7,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext context, dynamic item, ThemesProvider theme, dynamic mfData) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onLongPress: () async {
          try {
            final isin = item.iSIN;
            if (isin != null) {
              await mfData.fetchMFWatchlist(
                isin,
                "delete",
                context,
                true,
                "watch",
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                successMessage(context, "Missing fund information")
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              successMessage(context, "Error updating watchlist: ${e.toString()}")
            );
          }
        },
        onTap: () async {
          try {
            mfData.loaderfun();
            final isin = item.iSIN;
            if (isin != null) {
              await mfData.fetchFactSheet(isin);
              await mfData.fetchmatchisan(isin);
              Navigator.pushNamed(
                context,
                Routes.mfStockDetail,
                arguments: item,
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                successMessage(context, "Missing fund information")
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              successMessage(context, "Error loading fund details: ${e.toString()}")
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.symmetric(
              vertical: BorderSide(
                color: theme.isDarkMode
                    ? colors.darkGrey
                    : const Color(0xffEEF0F2),
                width: 0,
              ),
            ),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        "https://v3.mynt.in/mf/static/images/mf/${item.aMCCode ?? 'default'}.png",
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.schemegroupName ?? "Unknown Scheme",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textStyles.scripNameTxtStyle.copyWith(
                            color: theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: SizedBox(
                            height: 18,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                CustomExchBadge(
                                  exch: item.type ?? "Unknown"
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: CustomExchBadge(
                                    exch: item.schemeType ?? "Unknown",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatReturns(item.tHREEYEARDATA),
                    style: textStyle(
                      _getReturnColor(item.tHREEYEARDATA),
                      14,
                      FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Divider(
                  color: theme.isDarkMode
                      ? colors.darkColorDivider
                      : colors.colorDivider,
                  thickness: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatReturns(String? returns) {
    if (returns == null || returns.isEmpty) {
      return "0.00%";
    }
    return "$returns%";
  }

  Color _getReturnColor(String? returns) {
    if (returns == null || returns.isEmpty) {
      return Colors.grey;
    }
    
    try {
      final value = double.parse(returns);
      return value >= 0 ? Colors.green : Colors.red;
    } catch (e) {
      return Colors.grey;
    }
  }
}