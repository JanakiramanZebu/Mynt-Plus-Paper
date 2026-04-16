import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SidebarController extends Notifier<Widget?> {
  GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  Widget? build() => null;

  void setScaffoldKey(GlobalKey<ScaffoldState> key) {
    scaffoldKey = key;
  }

  void setSidebar(Widget? content) {
    state = content;
  }

  void openSidebar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scaffoldKey?.currentState?.openEndDrawer();
    });
  }
}

final sidebarProvider = NotifierProvider<SidebarController, Widget?>(SidebarController.new);
