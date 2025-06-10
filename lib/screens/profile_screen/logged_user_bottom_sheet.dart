import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../locator/locator.dart';
import '../../locator/preference.dart';
import '../../provider/auth_provider.dart';
import '../../provider/index_list_provider.dart';
import '../../provider/ledger_provider.dart';
import '../../provider/order_provider.dart';
import '../../provider/portfolio_provider.dart';
import '../../provider/thems.dart';
import '../../provider/user_profile_provider.dart';
import '../../provider/websocket_provider.dart';
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

    final Preferences pref = locator<Preferences>();
    return DraggableScrollableSheet(
        expand: false,
        initialChildSize: loggedUser.loggedMobile.length > 3 ? 0.79 : 0.35,
        minChildSize: 0.25,
        maxChildSize: loggedUser.loggedMobile.length < 3 ? 0.5 : 0.9,
        builder: (_, controller) {
          return Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color:
                      theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0xff999999),
                        blurRadius: 4.0,
                        offset: Offset(2.0, 0.0))
                  ]),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CustomDragHandler(),
                    Padding(
                        padding: const EdgeInsets.only(left: 14.0, bottom: 10),
                        child: Text("Add / Switch account",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                16,
                                FontWeight.w500))),
                    Divider(
                        height: 1,
                        thickness: 1,
                        color: theme.isDarkMode
                            ? colors.darkColorDivider
                            : colors.colorDivider),
                    Expanded(
                        child: ListView.separated(
                            controller: controller,
                            shrinkWrap: true,
                            itemCount: loggedUser.loggedMobile.length,
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return const ListDivider();
                            },
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                  onTap: () async {
                                    if (loggedUser
                                            .loggedMobile[index].clientId !=
                                        pref.clientId) {
                                      userProfile.profilePageloader(true);

                                      // Clear data from previous account
                                      portfolio.clearAllportfolio();
                                      orders.clearAllorders();
                                      ledgerprovider.setterfornullallSwitch =
                                          null;
                                      userProfile.clearUserData();

                                      // Close WebSocket before changing account
                                      final websocket =
                                          ref.read(websocketProvider);
                                      websocket.closeSocket(true);

                                      // Set new account information
                                      pref.setClientId(loggedUser
                                          .loggedMobile[index].clientId);
                                      pref.setClientMob(loggedUser
                                          .loggedMobile[index].mobile);
                                      pref.setClientSession(loggedUser
                                          .loggedMobile[index].sesstion);
                                      pref.setClientName(loggedUser
                                          .loggedMobile[index].userName);
                                      pref.setImei(
                                          loggedUser.loggedMobile[index].imei);
                                      pref.setMobileLogin(true);

                                      await ref
                                          .read(authProvider)
                                          .fetchMobileLogin(
                                              context,
                                              "",
                                              loggedUser
                                                  .loggedMobile[index].clientId,
                                              "switchAc",
                                              loggedUser
                                                  .loggedMobile[index].imei,
                                              true);

                                      userProfile.profilePageloader(false);

                                      // Reset WebSocket connection count and reconnect
                                      websocket.changeconnectioncount();
                                    }
                                  },
                                  dense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14),
                                  title: Text(
                                      loggedUser.loggedMobile[index].userName,
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          14,
                                          FontWeight.w500)),
                                  subtitle: Text(
                                      "Client ID ${loggedUser.loggedMobile[index].clientId}",
                                      style: textStyle(const Color(0xff666666),
                                          12, FontWeight.w500)),
                                  trailing: loggedUser
                                              .loggedMobile[index].clientId ==
                                          pref.clientId
                                      ? Text("Active",
                                          style: textStyle(
                                              theme.isDarkMode
                                                  ? colors.colorLightBlue
                                                  : colors.colorBlue,
                                              13,
                                              FontWeight.w600))
                                      : InkWell(
                                          onTap: () {
                                            loggedUser.removeUsers(
                                                loggedUser.loggedMobile[index],
                                                index,
                                                context);
                                          },
                                          child: Text("Remove",
                                              style: textStyle(
                                                  theme.isDarkMode
                                                      ? colors.kColorLightRed
                                                      : colors.kColorRedButton,
                                                  13,
                                                  FontWeight.w600)),
                                        ));
                            })),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 5),
                        child: OutlinedButton(
                            onPressed: () {
                              // Clear all data from previous account before adding a new one
                              //   ref.read(portfolioProvider).clearAllportfolio();
                              ref.read(orderProvider).clearAllorders();
                              ref.read(ledgerProvider).setterfornullallSwitch =
                                  null;

                              // Clear any cached user profile data
                              //   ref.read(userProfileProvider).clearUserData();

                              //   pref.setMobileLogin(true);
                              //   pref.setLogout(false);
                              //   pref.setHideLoginOptBtn(true);
                              ref.watch(websocketProvider).closeSocket(true);

                              loggedUser.addClient(true);
                              loggedUser.clearError();
                              //   loggedUser.clearTextField();
                              loggedUser.loginMethCtrl.clear();

                              // Close bottom sheet
                              Navigator.pop(context);

                              // Navigate to login screen using a different approach
                              // that won't clear user data when returning via back button
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => PopScope(
                                    canPop: true,
                                    onPopInvokedWithResult:
                                        (didPop, result) async {
                                      if (didPop) {
                                        // Ensure we're still in the profile screen
                                        // when returning from login
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
                                    width: 1.4,
                                    color: theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.5),
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)))),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(assets.addCircleIcon,
                                      color: theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack),
                                  const SizedBox(width: 8),
                                  Text("Add account",
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          14,
                                          FontWeight.w500))
                                ]))),
                    const SizedBox(height: 12)
                  ]));
        });
  }
}
