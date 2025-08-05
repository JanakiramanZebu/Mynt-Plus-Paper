import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../locator/locator.dart';
import '../../locator/preference.dart';
import '../../provider/auth_provider.dart';
import '../../provider/fund_provider.dart';
import '../../provider/index_list_provider.dart';
import '../../provider/ledger_provider.dart';
import '../../provider/mf_provider.dart';
import '../../provider/order_provider.dart';
import '../../provider/portfolio_provider.dart';
import '../../provider/thems.dart';
import '../../provider/user_profile_provider.dart';
import '../../provider/websocket_provider.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../screens/authentication/login/login_screen.dart';
import '../../sharedWidget/custom_drag_handler.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/list_divider.dart';

class LoggedUserBottomSheet extends ConsumerWidget {
  final String initRoute;
  const LoggedUserBottomSheet({super.key, required this.initRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loggedUser = ref.watch(authProvider);
    final theme = ref.watch(themeProvider);
    final portfolio = ref.watch(portfolioProvider);
    final orders = ref.watch(orderProvider);
    final userProfile = ref.watch(userProfileProvider);
    final ledgerprovider = ref.watch(ledgerProvider);
    final mf = ref.watch(mfProvider);

    final Preferences pref = locator<Preferences>();

    // Identify active and other accounts
    final activeAccount = loggedUser.loggedMobile.firstWhere(
      (acc) => acc.clientId == pref.clientId,
      orElse: () => loggedUser.loggedMobile.first,
    );
    final otherAccounts = loggedUser.loggedMobile
        .where((acc) => acc.clientId != pref.clientId)
        .toList();

    return DraggableScrollableSheet(
      expand: false,
      // initialChildSize: loggedUser.loggedMobile.length > 3 ? 0.50 : 0.40,
      // minChildSize: 0.25,
      maxChildSize: loggedUser.loggedMobile.length < 3 ? 0.5 : 0.9,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
            boxShadow: const [
              BoxShadow(
                color: Color(0xff999999),
                blurRadius: 4.0,
                offset: Offset(2.0, 0.0),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomDragHandler(),

              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: TextWidget.titleText(
                  text: "Manage Accounts",
                  theme: false,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  fw: 1,
                ),
              ),

              Divider(
                color: theme.isDarkMode
                    ? colors.darkColorDivider
                    : colors.colorDivider,
                height: 0,
              ),
const SizedBox(height: 10,),
              // --- Current Account ListView ---
              SizedBox(
                height: 80,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 1,
                  separatorBuilder: (context, idx) => Divider(
                    color: colors.dividerDark,
                    height: 0,
                  ),
                  itemBuilder: (context, idx) {
                    return InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, top: 16, bottom: 16),
                        color: theme.isDarkMode
                            ? colors.colorWhite.withOpacity(0.05)
                            : colors.colorBlack.withOpacity(0.05),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Left side with avatar and text
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: theme.isDarkMode
                                      ? colors.colorBlue
                                      : colors.colorBlue,
                                  child: TextWidget.titleText(
                                    text: activeAccount.userName.isNotEmpty
                                        ? activeAccount.userName[0]
                                            .toUpperCase()
                                        : 'U',
                                    theme: false,
                                    color: colors.colorWhite,
                                    fw: 1,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    TextWidget.subText(
                                      text: activeAccount.userName,
                                      theme: false,
                                      color: theme.isDarkMode
                                          ? colors.textPrimaryDark
                                          : colors.textPrimaryLight,
                                      fw: 0,
                                    ),
                                    const SizedBox(height: 4),
                                    TextWidget.paraText(
                                      text: activeAccount.clientId,
                                      theme: false,
                                      color: !theme.isDarkMode
                                          ? colors.textSecondaryLight
                                          : colors.textSecondaryDark,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                
                            // Right side with logout button
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  // Add delay for visual feedback
                                  await Future.delayed(
                                      const Duration(milliseconds: 150));
                
                                  if (context.mounted) {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext dialogContext) {
                                        return AlertDialog(
                                          backgroundColor: colors.colorWhite,
                                          titlePadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 8),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8)),
                                          ),
                                          scrollable: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 12),
                                          actionsPadding: const EdgeInsets.only(
                                              bottom: 16,
                                              right: 16,
                                              left: 16,
                                              top: 8),
                                          insetPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 30, vertical: 12),
                                          title: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Material(
                                                    color: Colors.transparent,
                                                    shape: const CircleBorder(),
                                                    child: InkWell(
                                                      onTap: () async {
                                                        await Future.delayed(
                                                            const Duration(
                                                                milliseconds:
                                                                    150));
                                                        Navigator.pop(context);
                                                      },
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      splashColor: theme
                                                              .isDarkMode
                                                          ? colors.splashColorDark
                                                          : colors
                                                              .splashColorLight,
                                                      highlightColor: theme
                                                              .isDarkMode
                                                          ? colors.splashColorDark
                                                          : colors
                                                              .splashColorLight,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                                6.0),
                                                        child: Icon(
                                                          Icons.close_rounded,
                                                          size: 22,
                                                          color: theme.isDarkMode
                                                              ? colors.colorWhite
                                                              : colors.colorBlack,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    const SizedBox(height: 10),
                                                    TextWidget.subText(
                                                      text:
                                                          "Are you sure you want to logout?",
                                                      theme: theme.isDarkMode,
                                                      color: theme.isDarkMode
                                                          ? colors.textPrimaryDark
                                                          : colors
                                                              .textPrimaryLight,
                                                      fw: 3,
                                                      align: TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            SizedBox(
                                              width: double.infinity,
                                              child: OutlinedButton(
                                                onPressed: () async {
                                                  Navigator.of(dialogContext)
                                                      .pop();
                                                  await ref
                                                      .read(authProvider)
                                                      .fetchLogout(context);
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  minimumSize: const Size(0, 40),
                                                  side: BorderSide(
                                                      color: colors
                                                          .btnOutlinedBorder),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(5),
                                                  ),
                                                  backgroundColor:
                                                      colors.primaryDark,
                                                ),
                                                child: TextWidget.titleText(
                                                  text: "Logout",
                                                  theme: theme.isDarkMode,
                                                  color: !theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack,
                                                  fw: 0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(5),
                                splashColor: theme.isDarkMode
                                    ? colors.splashColorDark
                                    : colors.splashColorLight,
                                highlightColor: theme.isDarkMode
                                    ? colors.highlightDark
                                    : colors.highlightLight,
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: TextWidget.subText(
                                      text: "Log Out",
                                      theme: false,
                                      color: theme.isDarkMode
                                          ? colors.secondaryDark
                                          : colors.secondaryLight,
                                      align: TextAlign.center,
                                      fw: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const ListDivider(),

              // --- Other Accounts List ---
              Expanded(
                child: otherAccounts.isNotEmpty
                    ? ListView.separated(
                        controller: controller,
                        shrinkWrap: true,
                        itemCount: otherAccounts.length,
                        separatorBuilder: (context, idx) => const ListDivider(),
                        itemBuilder: (context, idx) {
                          final acc = otherAccounts[idx];
                          return InkWell(
                            onTap: () async {
                              // Navigator.pop(context);
                              // await Future.delayed(
                              //     const Duration(milliseconds: 500));
                              userProfile.profileloaderfun(true);
                              // portfolio.clearAllportfolio();
                              // orders.clearAllorders();
                              // ledgerprovider.setterfornullallSwitch = null;
                              ref.read(fundProvider).clearFunds();

                              userProfile.clearUserData();

                              final websocket = ref.read(websocketProvider);
                              websocket.closeSocket(true);

                              pref.setClientId(acc.clientId);
                              pref.setClientMob(acc.mobile);
                              pref.setClientSession(acc.sesstion);
                              pref.setClientName(acc.userName);
                              pref.setImei(acc.imei);
                              pref.setMobileLogin(true);

                              await ref.read(authProvider).fetchMobileLogin(
                                    context,
                                    "",
                                    acc.clientId,
                                    "switchAc",
                                    acc.imei,
                                    true,
                                  );

                              websocket.changeconnectioncount();
                              // Future.delayed(const Duration(seconds: 2), () {
                              // userProfile.profileloaderfun(false);
                              // });
                            },
                            child: Container(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 16, top: 16, bottom: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Left side with avatar and text
                                  Expanded(
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: colors.fundbuttonBg,
                                          child: TextWidget.titleText(
                                            text: acc.userName.isNotEmpty
                                                ? acc.userName[0].toUpperCase()
                                                : 'U',
                                            theme: false,
                                            color: theme.isDarkMode
                                                ? colors.textPrimaryDark
                                                : colors.textPrimaryLight,
                                            fw: 1,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextWidget.subText(
                                              text: acc.userName,
                                              theme: false,
                                              color: theme.isDarkMode
                                                  ? colors.textPrimaryDark
                                                  : colors.textPrimaryLight,
                                              fw: 0,
                                            ),
                                            const SizedBox(height: 4),
                                            TextWidget.paraText(
                                              text: acc.clientId,
                                              theme: false,
                                              color: theme.isDarkMode
                                                  ? colors.textSecondaryDark
                                                  : colors.textSecondaryLight,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Right side with remove button
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () async {
                                        final originalIndex = loggedUser
                                            .loggedMobile
                                            .indexWhere((element) =>
                                                element.clientId ==
                                                acc.clientId);
                                        if (originalIndex != -1) {
                                          loggedUser.removeUsers(
                                              acc, originalIndex, context);
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(5),
                                      splashColor: theme.isDarkMode
                                          ? colors.splashColorDark
                                          : colors.splashColorLight,
                                      highlightColor: theme.isDarkMode
                                          ? colors.highlightDark
                                          : colors.highlightLight,
                                      child: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: TextWidget.subText(
                                            text: "Remove",
                                            theme: false,
                                            color: !theme.isDarkMode
                                                ? colors.errorLight
                                                : colors.errorDark,
                                            align: TextAlign.center,
                                            fw: 2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : const SizedBox.shrink(),
              ),

              // --- Add Account Button ---
              SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(orderProvider).clearAllorders();
                      ref.read(ledgerProvider).setterfornullallSwitch = null;
                      pref.setMobileLogin(true);
                      pref.setLogout(false);
                      ref.watch(websocketProvider).closeSocket(true);

                      loggedUser.addClient(false);
                      loggedUser.clearError();
                      loggedUser.loginMethCtrl.clear();
                      ref.read(authProvider).switchbackbutton(false);

                      Navigator.pop(context);

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PopScope(
                            canPop: true,
                            onPopInvokedWithResult: (didPop, result) async {
                              if (didPop) {
                                ref
                                    .read(websocketProvider)
                                    .changeconnectioncount();
                                if (context.mounted) {
                                  ref
                                      .read(indexListProvider)
                                      .bottomMenu(4, context);
                                }
                              }
                            },
                            child: const LoginScreen(),
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: theme.isDarkMode
                            ? colors.primaryDark
                            : colors.primaryLight,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10.5),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // SvgPicture.asset(
                        //   assets.addCircleIcon,
                        //   color: theme.isDarkMode
                        //       ? colors.primaryDark
                        //       : colors.primaryLight,
                        // ),
                        // const SizedBox(width: 8),
                        TextWidget.subText(
                          text: "Add account",
                          theme: false,
                          color: theme.isDarkMode
                              ? colors.primaryDark
                              : colors.primaryLight,
                          fw: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
