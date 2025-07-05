import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../locator/locator.dart';
import '../../locator/preference.dart';
import '../../provider/auth_provider.dart';
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
              SizedBox(
                height: 8.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 14.0, bottom: 10),
                child: TextWidget.titleText(
                  text: "Manage Accounts",
                  theme: false,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  fw: 0,
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              SizedBox(
                height: 8.0,
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: theme.isDarkMode
                    ? colors.darkColorDivider
                    : colors.colorDivider,
              ),

              // --- Current Account Card ---
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Card(
                  color: colors.fundbuttonBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 18),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: colors.colorWhite,
                          child: Text(
                            activeAccount.userName.isNotEmpty
                                ? activeAccount.userName[0].toUpperCase()
                                : 'U',
                            style: TextStyle(
                                color: colors.colorBlack,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget.titleText(
                                text: activeAccount.userName,
                                theme: false,
                                color: theme.isDarkMode
                                    ? colors.textPrimaryDark
                                    : colors.textPrimaryLight,
                                fw: 0,
                              ),
                              const SizedBox(height: 6),
                              TextWidget.paraText(
                                text: activeAccount.clientId,
                                theme: false,
                                color: !theme.isDarkMode
                                    ? colors.textSecondaryLight
                                    : colors.textSecondaryDark,
                                fw: 3,
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: colors.fundbuttonBg,
                            side: BorderSide(
                              color: theme.isDarkMode
                                  ? colors.colorLightBlue
                                  : colors.colorBlue,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: ref
                                          .read(themeProvider)
                                          .isDarkMode
                                      ? const Color.fromARGB(255, 18, 18, 18)
                                      : colors.colorWhite,
                                  titleTextStyle: textStyles.appBarTitleTxt
                                      .copyWith(
                                          color:
                                              ref.read(themeProvider).isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack),
                                  contentTextStyle: textStyles.menuTxt,
                                  titlePadding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(14))),
                                  scrollable: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14),
                                  insetPadding: const EdgeInsets.symmetric(
                                      horizontal: 40),
                                  title: TextWidget.titleText(
                                      text: "Confirmation",
                                      theme: theme.isDarkMode,
                                      fw: 0),
                                  content: SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextWidget.titleText(
                                                text:
                                                    "Are you sure you want to logout?",
                                                theme: theme.isDarkMode,
                                                fw: 0),
                                          ])),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: TextWidget.subText(
                                            text: "No",
                                            theme: false,
                                            color: theme.isDarkMode
                                                ? colors.colorLightBlue
                                                : colors.colorBlue,
                                            fw: 0)),
                                    ElevatedButton(
                                        onPressed: () async {
                                          ref
                                              .read(authProvider)
                                              .fetchLogout(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                            elevation: 0,
                                            backgroundColor: theme.isDarkMode
                                                ? colors.colorbluegrey
                                                : colors.colorBlack,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            )),
                                        child: TextWidget.subText(
                                            text: "Yes",
                                            theme: false,
                                            color: !theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack,
                                            fw: 0)),
                                  ],
                                );
                              },
                            );
                          },
                          child: TextWidget.subText(
                              text: "Log Out",
                              theme: false,
                              color: !theme.isDarkMode
                                  ? colors.colorBlue
                                  : colors.colorLightBlue,
                              fw: 0,
                              align: TextAlign.center),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              // --- Other Accounts List ---
              if (otherAccounts.isNotEmpty)
                Expanded(
                  child: ListView.separated(
                    controller: controller,
                    shrinkWrap: true,
                    itemCount: otherAccounts.length,
                    separatorBuilder: (context, idx) => const ListDivider(),
                    itemBuilder: (context, idx) {
                      final acc = otherAccounts[idx];
                      return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: colors.fundbuttonBg,
                            child: Text(
                              acc.userName.isNotEmpty
                                  ? acc.userName[0].toUpperCase()
                                  : 'U',
                              style: TextStyle(
                                  color: colors.colorBlack,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          onTap: () async {
                            mf.loaderfun();
                            portfolio.clearAllportfolio();
                            orders.clearAllorders();
                            ledgerprovider.setterfornullallSwitch = null;
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
                            Future.delayed(const Duration(seconds: 2), () {
                              mf.loaderfunfalse();
                            });
                          },
                          dense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 14),
                          title: TextWidget.subText(
                            text: acc.userName,
                            theme: false,
                            color: theme.isDarkMode
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight,
                            fw: 0,
                          ),
                          subtitle: TextWidget.paraText(
                            text: acc.clientId,
                            theme: false,
                            color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                            fw: 3,
                          ),
                          trailing: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: colors.fundbuttonBg,
                              side: BorderSide(
                                color: theme.isDarkMode
                                    ? colors.kColorLightRed
                                    : colors.kColorRedButton,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              loggedUser.removeUsers(acc, idx, context);
                            },
                            child: TextWidget.paraText(
                                text: "Remove",
                                theme: false,
                                color: !theme.isDarkMode
                                    ? colors.kColorRedButton
                                    : colors.kColorLightRed,
                                fw: 0,
                                align: TextAlign.center),
                          )

                          // InkWell(
                          //   onTap: () {
                          //     loggedUser.removeUsers(acc, idx, context);
                          //   },
                          //   child: TextWidget.subText(
                          //     text: "Remove",
                          //     theme: false,
                          //     color: theme.isDarkMode
                          //         ? colors.kColorLightRed
                          //         : colors.kColorRedButton,
                          //     fw: 1,
                          //   ),
                          // ),
                          );
                    },
                  ),
                ),

              // --- Add Account Button ---
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
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
                                ref.read(indexListProvider).bottomMenu(4, context);
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
                      width: 1.4,
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
                      SvgPicture.asset(
                        assets.addCircleIcon,
                        color: theme.isDarkMode
                            ? colors.primaryDark
                            : colors.primaryLight,
                      ),
                      const SizedBox(width: 8),
                      TextWidget.subText(
                        text: "Add account",
                        theme: false,
                        color: theme.isDarkMode
                            ? colors.primaryDark
                            : colors.primaryLight,
                        fw: 0,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
