import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../provider/mf_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../sharedWidget/no_data_found.dart';
import '../../../../res/res.dart';
import '../../../../res/global_state_text.dart';
import 'mf_sip_detail_screen_web.dart';
import '../../../../models/mf_model/sip_mf_list_model.dart';

class MFSipdetScreenWeb extends ConsumerStatefulWidget {
  const MFSipdetScreenWeb({super.key});

  @override
  ConsumerState<MFSipdetScreenWeb> createState() => _MFSipdetScreenWebState();
}

class _MFSipdetScreenWebState extends ConsumerState<MFSipdetScreenWeb> {
  int? _sipSortColumnIndex;
  bool _sipSortAscending = true;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final mf = ref.watch(mfProvider);

    final sipDetails = mf.mfsiporderlist?.data ?? [];

    return Container(
      decoration: BoxDecoration(
        color: theme.isDarkMode
            ? colors.kColorLightGreyDarkTheme
            : colors.kColorLightGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        ),
      ),
      child: sipDetails.isEmpty
          ? const SizedBox(
              height: 400,
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: NoDataFound(),
                ),
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: const AlwaysScrollableScrollPhysics(),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  child: IntrinsicWidth(
                    child: DataTable(
                    showCheckboxColumn: false,
                    sortColumnIndex: _sipSortColumnIndex,
                    sortAscending: _sipSortAscending,
                    headingRowColor: WidgetStateProperty.all(
                      theme.isDarkMode
                          ? colors.kColorLightGreyDarkTheme
                          : colors.kColorLightGrey,
                    ),
                    dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return (theme.isDarkMode
                                  ? colors.primaryDark
                                  : colors.primaryLight)
                              .withOpacity(0.1);
                        }
                        return null;
                      },
                    ),
                    columns: [
                      DataColumn(
                        label: _buildSortableColumnHeader('Scheme', theme,
                            isActive: _sipSortColumnIndex == 0,
                            ascending: _sipSortAscending),
                        onSort: (i, asc) => _onSortSipTable(0),
                      ),
                      DataColumn(
                        label: _buildSortableColumnHeader('SIP Reg No', theme,
                            isActive: _sipSortColumnIndex == 1,
                            ascending: _sipSortAscending),
                        onSort: (i, asc) => _onSortSipTable(1),
                      ),
                      DataColumn(
                        label: _buildSortableColumnHeader('Amount', theme,
                            isActive: _sipSortColumnIndex == 2,
                            ascending: _sipSortAscending),
                        onSort: (i, asc) => _onSortSipTable(2),
                      ),
                      DataColumn(
                        label: _buildSortableColumnHeader('Frequency', theme,
                            isActive: _sipSortColumnIndex == 3,
                            ascending: _sipSortAscending),
                        onSort: (i, asc) => _onSortSipTable(3),
                      ),
                      DataColumn(
                        label: _buildSortableColumnHeader(
                            'Next Installment', theme,
                            isActive: _sipSortColumnIndex == 4,
                            ascending: _sipSortAscending),
                        onSort: (i, asc) => _onSortSipTable(4),
                      ),
                      DataColumn(
                        label: _buildSortableColumnHeader('Status', theme,
                            isActive: _sipSortColumnIndex == 5,
                            ascending: _sipSortAscending),
                        onSort: (i, asc) => _onSortSipTable(5),
                      ),
                    ],
                    rows: _sortedSipDetails(sipDetails).map((s) {
                      final scheme = s.name ?? '';
                      final reg = s.sIPRegnNo ?? '';
                      final amount = s.installmentAmount?.toString() ?? '0';
                      final freq = s.frequencyType ?? '';
                      final nextInst = s.NextSIPDate ?? '';
                      final status = (s.status ?? '').toUpperCase();
                      final statusColor = _statusColor(status, theme);

                      return DataRow(
                        selected: false,
                        onSelectChanged: (bool? selected) {
                          if (selected == true) {
                            _openSipDetail(s);
                          }
                        },
                        cells: [
                          DataCell(Text(scheme, style: _cellStyle(theme))),
                          DataCell(Text(reg, style: _cellStyle(theme))),
                          DataCell(Text(amount, style: _cellStyle(theme))),
                          DataCell(Text(freq, style: _cellStyle(theme))),
                          DataCell(Text(nextInst, style: _cellStyle(theme))),
                          DataCell(Text(
                            status,
                            style: TextWidget.textStyle(
                              fontSize: 12,
                              color: statusColor,
                              theme: theme.isDarkMode,
                              fw: 2,
                            ),
                          )),
                        ],
                      );
                    }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            );
  }

  TextStyle _cellStyle(ThemesProvider theme) => TextWidget.textStyle(
        fontSize: 12,
        color:
            theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
        theme: theme.isDarkMode,
        fw: 2,
      );

  Widget _buildSortableColumnHeader(String label, ThemesProvider theme,
      {bool isActive = false, bool ascending = true}) {
    return Text(
      label,
      style: TextWidget.textStyle(
        fontSize: 12,
        color: theme.isDarkMode
            ? colors.textSecondaryDark
            : colors.textSecondaryLight,
        theme: theme.isDarkMode,
        fw: 2,
      ),
    );
  }

  void _onSortSipTable(int columnIndex) {
    setState(() {
      if (_sipSortColumnIndex == columnIndex) {
        _sipSortAscending = !_sipSortAscending;
      } else {
        _sipSortColumnIndex = columnIndex;
        _sipSortAscending = true;
      }
    });
  }

  List<dynamic> _sortedSipDetails(List<dynamic> sipDetails) {
    if (_sipSortColumnIndex == null) return sipDetails;
    final sorted = [...sipDetails];
    int c = _sipSortColumnIndex!;
    bool asc = _sipSortAscending;

    int cmp<T extends Comparable>(T? a, T? b) {
      if (a == null && b == null) return 0;
      if (a == null) return -1;
      if (b == null) return 1;
      return a.compareTo(b);
    }

    num parseNum(String? v) => double.tryParse(v ?? '') ?? 0;

    sorted.sort((a, b) {
      int r = 0;
      switch (c) {
        case 0: // Scheme
          r = cmp<String>(a.name, b.name);
          break;
        case 1: // SIP Reg No
          r = cmp<String>(a.sIPRegnNo, b.sIPRegnNo);
          break;
        case 2: // Amount
          r = cmp<num>(parseNum(a.installmentAmount?.toString()),
              parseNum(b.installmentAmount?.toString()));
          break;
        case 3: // Frequency
          r = cmp<String>(a.frequencyType, b.frequencyType);
          break;
        case 4: // Next Installment
          r = cmp<String>(a.NextSIPDate, b.NextSIPDate);
          break;
        case 5: // Status
          r = cmp<String>(a.status, b.status);
          break;
      }
      return asc ? r : -r;
    });
    return sorted;
  }

  Color _statusColor(String status, ThemesProvider theme) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'running':
        return theme.isDarkMode ? colors.profitDark : colors.profitLight;
      case 'stopped':
      case 'cancelled':
      case 'rejected':
        return theme.isDarkMode ? colors.lossDark : colors.lossLight;
      default:
        return colors.pending;
    }
  }

  void _openSipDetail(Xsip sipDetail) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MFSipDetailScreenWeb(sipData: sipDetail);
      },
    );
  }
}
