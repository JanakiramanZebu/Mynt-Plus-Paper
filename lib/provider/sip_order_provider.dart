import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart'; 
import '../api/core/api_export.dart';
import '../locator/locator.dart'; 
import '../locator/preference.dart';
import '../models/order_book_model/sip_order_book.dart';
import '../models/order_book_model/sip_order_cancel.dart';
import '../models/order_book_model/sip_place_order.dart'; 
import '../sharedWidget/snack_bar.dart';
import 'auth_provider.dart';
import 'core/default_change_notifier.dart';
import 'index_list_provider.dart'; 
final siprovider = ChangeNotifierProvider((ref) => SipProvider(ref.read));

class SipProvider extends DefaultChangeNotifier {  final Preferences pref = locator<Preferences>();
  final api = locator<ApiExporter>();
  final Reader ref;
  SipProvider(this.ref);
  final FToast _fToast = FToast();
  FToast get fToast => _fToast;

  final TextEditingController textCtrl = TextEditingController();
  final TextEditingController datefield = TextEditingController();
  final TextEditingController enddatefield = TextEditingController();
  final TextEditingController duration = TextEditingController();

  String? textCtrlError, durationError;

  SipPlaceOrderModel? _sipPlaceOrder;
  SipPlaceOrderModel? get sipPlaceOrder => _sipPlaceOrder;

  SipOrderBookModel? _siporderBookModel;
  SipOrderBookModel? get siporderBookModel => _siporderBookModel;

  CancleSipOrder? _cancleSipOrder;
  CancleSipOrder? get cancleSipOrder => _cancleSipOrder;

  startdatemethod(int dws) {
    DateTime selectedStartDate = DateTime.now();
    String sd = DateFormat('dd-MM-yyyy').format(selectedStartDate);
    datefield.text = sd;
    DateTime selectedEndDate = DateTime.now().add(Duration(days: dws));
    String ed = DateFormat('dd-MM-yyyy').format(selectedEndDate);
    enddatefield.text = ed;
  }

  fetchSipPlaceOrder(BuildContext context, SipInputField sipOrderInput) async {
    
    try {
      toggleLoadingOn(true);
      
     

      _sipPlaceOrder = await api.getPlaceSipOrder(sipOrderInput);
      if (_sipPlaceOrder!.reqStatus == "OK") {
        ref(indexListProvider).bottomMenu(3);

        fetchSipOrderHistory();
        ScaffoldMessenger.of(context).showSnackBar(
            successMessage(context, "Order is Placed Sucessfully"));
      } else if (_sipPlaceOrder!.stat == "Not_Ok") {
        ref(authProvider). ifSessionExpired(  context);
      }

      notifyListeners();
    } catch (e) {
      ref(indexListProvider).logError.add({"type": "API", "Error": "$e"});
      notifyListeners();
    } finally {
      

      toggleLoadingOn(false);
    }
  }

  Future fetchSipOrderHistory() async {
    
    try {
      toggleLoadingOn(true);
      
      _siporderBookModel = await api.getSipOrderBook();
      notifyListeners();

      return _siporderBookModel;
    } catch (e) {
      ref(indexListProvider).logError.add({"type": "API", "Error": "$e"});
      notifyListeners();
    } finally {
      

      toggleLoadingOn(false);
    }
  }

  Future fetchSipOrderCancel(String sipOrderno, context) async {
    
    try {
      
      _cancleSipOrder = await api.getSipCancelOrder(sipOrderno);
      await fetchSipOrderHistory();
      if (_cancleSipOrder!.reqStatus == "OK") {
        ScaffoldMessenger.of(context)
            .showSnackBar(successMessage(context, "Order Sucessfully Cancled"));
      }

      return _cancleSipOrder;
    } catch (e) {
      ref(indexListProvider).logError.add({"type": "API", "Error": "$e"});
      notifyListeners();
    } finally {
      
    }
  }

  Future providedate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData(
              primarySwatch: Colors.grey,
              splashColor: Colors.black,
              // textTheme: const TextTheme(
              //   titleMedium: TextStyle(color: Colors.black),
              //   labelLarge: TextStyle(color: Colors.black),
              // ),
              colorScheme: const ColorScheme.light(
                primary: Color(0xff0037B7),
              ),
              dialogBackgroundColor: Colors.white,
            ),
            child: child ?? const Text(""),
          );
        },
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 0)),
        lastDate: DateTime(2101));

    if (pickedDate != null) {
      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);

      datefield.text = formattedDate;
    }
    notifyListeners();
  }

  Future enddate(BuildContext context, int value) async {
    DateTime? pickedDate = await showDatePicker(
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData(
              primarySwatch: Colors.grey,
              splashColor: Colors.black,
              // textTheme: const TextTheme(
              //   titleMedium: TextStyle(color: Colors.black),
              //   labelLarge: TextStyle(color: Colors.black),
              // ),
              colorScheme: const ColorScheme.light(
                primary: Color(0xff000000),
              ),
              dialogBackgroundColor: Colors.white,
            ),
            child: child ?? const Text(""),
          );
        },
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        context: context,
        initialDate: DateTime.now().add(Duration(days: value)),
        firstDate: DateTime.now().add(Duration(days: value)),
        lastDate: DateTime(2101));

    if (pickedDate != null) {
      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);

      enddatefield.text = formattedDate;
    }
    notifyListeners();
  }
}
