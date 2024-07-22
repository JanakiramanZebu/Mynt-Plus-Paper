import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:google_fonts/google_fonts.dart'; 
import '../../../provider/notification_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_back_btn.dart';
import 'tabs/broker_message.dart';
import 'tabs/exchange_message.dart';



class Notificationpage extends StatefulWidget {
  const Notificationpage({super.key});


  @override
  State<Notificationpage> createState() => _NotificationpageState();
}


class _NotificationpageState extends State<Notificationpage>
    with TickerProviderStateMixin {
  @override
  void initState() {
    context.read(notificationprovider).notifytab = TabController(
        length: context.read(notificationprovider).notifyTabName.length,
        vsync: this,
        initialIndex: context.read(notificationprovider).selectedTab);


    context.read(notificationprovider).notifytab.addListener(() {
      context
          .read(notificationprovider)
          .changeTabIndex(context.read(notificationprovider).notifytab.index);
      context.read(notificationprovider).tabSize();
    });


    super.initState();
  }


  @override
  Widget build(BuildContext context) {
      final theme =context.read(themeProvider);
    return Scaffold(
     
      appBar: AppBar(
          elevation: .2,
          centerTitle: false,
          leadingWidth: 41,
          titleSpacing: 6,
          leading: const CustomBackBtn(),
          
          title: Text("Notificaton", style: textStyles.appBarTitleTxt.copyWith(color: theme.isDarkMode?colors.colorWhite:colors.colorBlack))),
      body: Consumer(builder: (context, ScopedReader watch, _) {
        final notification = watch(notificationprovider);
        return Column(
          children: [
            Container(
              decoration:   BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color:theme.isDarkMode?colors.darkColorDivider:colors.colorDivider,width: 0))),
                width: MediaQuery.of(context).size.width,           
                height: 46,
                child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorColor:  theme.isDarkMode?colors.colorLightBlue:colors.colorBlue,
                    unselectedLabelColor: const Color(0XFF777777),
                    unselectedLabelStyle: GoogleFonts.inter(
                        textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.28)),
                    labelColor: theme.isDarkMode?colors.colorLightBlue:colors.colorBlue,
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





