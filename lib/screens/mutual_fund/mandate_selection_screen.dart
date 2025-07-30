import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/mf_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:mynt_plus/sharedWidget/list_divider.dart';
import '../mutual_fund_old/create_mandate_daialogue.dart';
import '../../../provider/thems.dart';

class MandateSelectionScreen extends StatefulWidget {
  final String? currentMandateId;
  final Function(String) onMandateSelected;

  const MandateSelectionScreen({
    Key? key,
    this.currentMandateId,
    required this.onMandateSelected,
  }) : super(key: key);

  @override
  State<MandateSelectionScreen> createState() => _MandateSelectionScreenState();
}

class _MandateSelectionScreenState extends State<MandateSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, WidgetRef ref, _) {
        final theme = ref.read(themeProvider);
        final mfOrder = ref.watch(mfProvider);

        return Scaffold(
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Material(
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
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back_ios_outlined,
                    size: 18,
                    color:
                        theme.isDarkMode ? colors.colorGrey : colors.colorBlack,
                  ),
                ),
              ),
            ),
            elevation: 0,
            centerTitle: false,
            titleSpacing: -8,
            title: TextWidget.titleText(
                text: "Auto Pay (Mandates)",
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 0),
          ),
          backgroundColor:
              theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          body: Column(
            children: [
              // Create Mandate Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const CreateMandateDialogue();
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: !theme.isDarkMode
                          ? colors.primaryLight
                          : colors.primaryDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: TextWidget.subText(
                      text: "Create New Mandate",
                      theme: !theme.isDarkMode,
                      color: !theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                      fw: 0,
                    ),
                  ),
                ),
              ),

              // Mandate List
              Expanded(
                child: mfOrder.mandateData != null &&
                        mfOrder.mandateData!.isNotEmpty
                    ? ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: mfOrder.mandateData!.length,
                        separatorBuilder: (context, index) =>
                            const ListDivider(),
                        itemBuilder: (context, index) {
                          final mandate = mfOrder.mandateData![index];
                          final isSelected =
                              mandate.mandateId == widget.currentMandateId;

                          return InkWell(
                            onTap: () {
                              widget.onMandateSelected(mandate.mandateId ?? '');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (theme.isDarkMode
                                        ? colors.primaryDark.withOpacity(0.1)
                                        : colors.primaryLight.withOpacity(0.1))
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? (theme.isDarkMode
                                          ? colors.primaryDark
                                          : colors.primaryLight)
                                      : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextWidget.subText(
                                          text:
                                              "Mandate ID: ${mandate.mandateId}",
                                          theme: theme.isDarkMode,
                                          color: theme.isDarkMode
                                              ? colors.textPrimaryDark
                                              : colors.textPrimaryLight,
                                          fw: 0,
                                        ),
                                        const SizedBox(height: 4),
                                        TextWidget.paraText(
                                          text: "Amount: ${mandate.amount}",
                                          theme: theme.isDarkMode,
                                          color: colors.colorGrey,
                                        ),
                                        const SizedBox(height: 4),
                                        TextWidget.paraText(
                                          text: "Status: ${mandate.status}",
                                          theme: theme.isDarkMode,
                                          color: colors.colorGrey,
                                        ),
                                        if (mandate.bankName != null) ...[
                                          const SizedBox(height: 4),
                                          TextWidget.paraText(
                                            text: "Bank: ${mandate.bankName}",
                                            theme: theme.isDarkMode,
                                            color: colors.colorGrey,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: theme.isDarkMode
                                          ? colors.primaryDark
                                          : colors.primaryLight,
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: colors.colorGrey,
                            ),
                            const SizedBox(height: 16),
                            TextWidget.subText(
                              text: "No Mandates Found",
                              theme: theme.isDarkMode,
                              color: theme.isDarkMode
                                  ? colors.textPrimaryDark
                                  : colors.textPrimaryLight,
                              fw: 0,
                            ),
                            const SizedBox(height: 8),
                            TextWidget.paraText(
                              text: "Create a new mandate to get started",
                              theme: theme.isDarkMode,
                              color: colors.colorGrey,
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
