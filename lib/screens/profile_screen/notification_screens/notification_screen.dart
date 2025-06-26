import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../provider/notification_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_back_btn.dart';
import 'tabs/broker_message.dart';
import 'tabs/exchange_message.dart';

class Notificationpage extends ConsumerStatefulWidget {
  const Notificationpage({super.key});

  @override
  ConsumerState<Notificationpage> createState() => _NotificationpageState();
}

class _NotificationpageState extends ConsumerState<Notificationpage>
    with TickerProviderStateMixin {
  @override
  void initState() {
    ref.read(notificationprovider).notifytab = TabController(
        length: ref.read(notificationprovider).notifyTabName.length,
        vsync: this,
        initialIndex: ref.read(notificationprovider).selectedTab);

    ref.read(notificationprovider).notifytab.addListener(() {
      ref
          .read(notificationprovider)
          .changeTabIndex(ref.read(notificationprovider).notifytab.index);
      ref.read(notificationprovider).tabSize();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
    return Scaffold(
      appBar: AppBar(
          elevation: .2,
          centerTitle: false,
          leadingWidth: 41,
          titleSpacing: 6,
          leading: const CustomBackBtn(),
          title: TextWidget.titleText(
            text: "Notificaton",
            theme: false,
            color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
          )),
      body: Consumer(builder: (context, WidgetRef ref, _) {
        final notification = ref.watch(notificationprovider);
        return Column(
          children: [
            Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: theme.isDarkMode
                                ? colors.darkColorDivider
                                : colors.colorDivider,
                            width: 0))),
                width: MediaQuery.of(context).size.width,
                height: 46,
                child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorColor: theme.isDarkMode
                        ? colors.colorLightBlue
                        : colors.colorBlue,
                    unselectedLabelColor: const Color(0XFF777777),
                    unselectedLabelStyle: GoogleFonts.inter(
                        textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.28)),
                    labelColor: theme.isDarkMode
                        ? colors.colorLightBlue
                        : colors.colorBlue,
                    labelStyle: GoogleFonts.inter(
                        textStyle: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    controller: notification.notifytab,
                    tabs: notification.notifyTabName)),
            Expanded(
                child: TabBarView(
                    controller: notification.notifytab,
                    children: const [
                  BrokerMsg(),
                  ExchangeMessage(),
                ]))
          ],
        );
      }),
    );
  }
}
