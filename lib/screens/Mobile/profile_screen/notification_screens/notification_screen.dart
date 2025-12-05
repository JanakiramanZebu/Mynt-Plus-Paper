import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../provider/notification_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/custom_back_btn.dart';
import 'tabs/broker_message.dart';
import 'tabs/exchange_message.dart';
import 'tabs/information_message.dart';

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
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            fw: 1,
          )),
      body: Consumer(builder: (context, WidgetRef ref, _) {
        final notification = ref.watch(notificationprovider);
        return SafeArea(
          child: Column(
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
                          ? colors.secondaryDark
                          : colors.secondaryLight,
                      unselectedLabelColor: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                      unselectedLabelStyle: TextWidget.textStyle(
                        fontSize: 14,
                        theme: false,
                        color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                        fw: 2,
                    
                      ),
                      labelColor: theme.isDarkMode
                                  ? colors.secondaryDark
                                  : colors.secondaryLight,
                      labelStyle: TextWidget.textStyle(
                        fontSize: 14,
                        theme: false,
                        color:theme.isDarkMode
                                  ? colors.secondaryDark
                                  : colors.secondaryLight,
                        fw: 2,
                      ),
                      controller: notification.notifytab,
                      tabs: notification.notifyTabName)),
              Expanded(
                  child: TabBarView(
                      controller: notification.notifytab,
                      children: const [
                    BrokerMsg(),
                    ExchangeMessage(),
                    InformationMessage(),
                  ]))
            ],
          ),
        );
      }),
    );
  }
}
