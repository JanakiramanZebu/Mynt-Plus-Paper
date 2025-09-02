import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/api/core/api_export.dart';
import 'package:mynt_plus/locator/locator.dart';
import 'package:mynt_plus/locator/preference.dart';
import 'package:mynt_plus/models/client_profile_all_details/profile_all_details_model.dart';
import 'package:mynt_plus/provider/core/default_change_notifier.dart';
import 'package:mynt_plus/provider/fund_provider.dart';
import 'package:mynt_plus/screens/profile_screen/in_app_webview_screen.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../screens/profile_screen/profile_main_screen.dart';


final profileAllDetailsProvider =
    ChangeNotifierProvider((ref) => ProfileProvider(ref));

class ProfileProvider extends DefaultChangeNotifier {
  final api = locator<ApiExporter>();
  final Preferences pref = locator<Preferences>();
  final Ref ref;
  ProfileProvider(this.ref);

  late ProfileAllDetails _clientAllDetails;
  ProfileAllDetails get clientAllDetails => _clientAllDetails;

  final allDetailsSectionList = [
    'Personal Info',
    'Bank',
    'Demat',
    'Trading Preference',
    'MTF',
    'Annual Income',
    'Nominee',
    'Family Account',
    'Closure',
  ];

  String _allDetailsSelectedSection = 'Personal Info';
  String get allDetailsSelectedSection => _allDetailsSelectedSection;

  set setAllDetailsSelectedSection(String selectedTab) {
    _allDetailsSelectedSection = selectedTab;
  }

// On Personal Info Tab Section
  final TextEditingController newEmailController = TextEditingController();
  final TextEditingController newEmailOTPController = TextEditingController();

  final TextEditingController newMobController = TextEditingController();
  final TextEditingController newMobOTPController = TextEditingController();

  final TextEditingController newAddressController = TextEditingController();
  final TextEditingController newAddressPincodeController =
      TextEditingController();
  final TextEditingController newAddressDistrictController =
      TextEditingController();
  final TextEditingController newAddressStateController =
      TextEditingController();
  final TextEditingController newAddressCountryController =
      TextEditingController();
  final TextEditingController newAddressProofTypeController =
      TextEditingController();

// On Bank Tab Section
  final TextEditingController newBankAccController = TextEditingController();
  final TextEditingController newBankIFSCController = TextEditingController();
  bool selectedBankTypeValue = false;
  String? selectedBankProofTypeValue;

// On Annual Income Tab Section
  final List<String> annualIncomeRangeList = [
    'Below 1L',
    '1L to 5L',
    '5L to 10L',
    '10L to 25L',
    'Above 25L'
  ];
  final int selectedAnnualIncomeRangeValue = 1;
  final TextEditingController newIncomeOTPController = TextEditingController();

// On Account Closure Tab Section
  String? selectedAccountClosureReasonValue;

  final TextEditingController closureDPIDController = TextEditingController();
  final TextEditingController closureBOIDController = TextEditingController();

// On family Account Tab Section
  final TextEditingController newFamilyMemberIDController =
      TextEditingController();
  final TextEditingController newFamilyRelationshipController =
      TextEditingController();
  final TextEditingController newFamilyPANController = TextEditingController();
  final TextEditingController newFamilyMobController = TextEditingController();

  String? _responseval = "";
  String? get responseval => _responseval;

  String? _emilotpres = "";
  String? get emilotpres => _emilotpres;

  String? _mobileotpo = "";
  String? get mobileotp => _mobileotpo;

  String? _mobileotpverres = "";
  String? get mobileotpverres => _mobileotpverres;

  String? _manualaddbank = "";
  String? get manualaddbank => _manualaddbank;

  String? _ddpiledgerbalace = "";
  String? get ddpiledgerbalace => _ddpiledgerbalace;

  String? _ddpiesignfile = "";
  String? get ddpiesignfile => _ddpiesignfile;

  String? _mtfenabrespoce = "";
  String? get mtfenabrespoce => _mtfenabrespoce;

  String? _imcomeptsenres = "";
  String? get imcomeptsenres => _imcomeptsenres;

  String? _incomeotpverres = "";
  String? get incomeotpverres => _incomeotpverres;

  String? _incomupdaqres = "";
  String? get incomupdaqres => _incomupdaqres;

  String? _ifsccoderess = "";
  String? get ifsccoderess => _ifsccoderess;

  String? _banksumbres = "";
  String? get banksumbres => _banksumbres;

  String? _familyaccress = "";
  String? get familyaccress => _familyaccress;

  Map<String, dynamic> _chackaccbalace = {};
  Map<String, dynamic> get chackaccbalace => _chackaccbalace;
  clearProfilePop(BuildContext context, String type) {
    if (type == "email") {
      _responseval = "";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Some error occurred")),
      );
    }
    if (type == "emailotp") {
      _emilotpres = "";
    }
    if (type == "mobile") {
      _mobileotpo = "";
    }

    if (type == "mobilotp") {
      _mobileotpverres = "";
    }

    if (type == "manbank") {
      _manualaddbank = "";
    }
    if (type == "ddpibalace") {
      _ddpiledgerbalace = "";
    }
    if (type == "incomeotpres") {
      _imcomeptsenres = "";
    }

    if (type == "bankifsc") {
      _ifsccoderess = "";
    }
    if (type == "accclose") {
      _chackaccbalace = {};
    }
  }

  validateChnageEmail() {}

  formateDataToDisplay(String data, int firstPart, int lastPart) {
    if (data.length > 1) {
      int remaining = data.length - lastPart;
      return "${data.substring(0, firstPart)} ********* ${data.substring(remaining)}";
    } else {
      return "";
    }
    // profileprovider.clientAllDetails.bankData![index].bankAcNo?.length - 4 ;
  }

// void downloadFile(String url) {
//    html.AnchorElement anchorElement =  new html.AnchorElement(href: url);
//    anchorElement.download = url;
//    anchorElement.click();
// }

  void openInWebURL(BuildContext context, String urlArgs) async {
    await ref.read(fundProvider).fetchHstoken(context);
    debugPrint(
        '$urlArgs  ==== ${pref.clientId} =====  ${ref.read(fundProvider).fundHstoken!.hstk}');
    String url = 'https://profile.mynt.in/${urlArgs}/?sAccountId=${pref.clientId}&sToken=${ref.read(fundProvider).fundHstoken!.hstk}';
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InAppWebViewScreen(url: url),
      ),
    );
  }
  void openInWebURLWithbank(BuildContext context, String urlArgs, String type, String bankAcNo) async {
    await ref.read(fundProvider).fetchHstoken(context);
    debugPrint(
        '$urlArgs  ==== ${pref.clientId} =====  ${ref.read(fundProvider).fundHstoken!.hstk}');
    String url = 'https://profile.zebuetrade.com/${urlArgs}/?uid=${pref.clientId}&token=${pref.token}&type=${type}&acno=${bankAcNo}&src=mobileapp';
    
     Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => InAppWebViewScreen(url: url),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }

  void openInWebURLk(BuildContext context, String urlArgs, String type) async {
    await ref.read(fundProvider).fetchHstoken(context);
    debugPrint(
        '$urlArgs  ==== ${pref.clientId} =====  ${ref.read(fundProvider).fundHstoken!.hstk}');
    String url = 'https://profile.zebuetrade.com/${urlArgs}/?uid=${pref.clientId}&token=${pref.token}&type=${type}&src=mobileapp';
    print("jdhfdfhhfdjksjhdjurl ::: $url");
     Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => InAppWebViewScreen(url: url),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }

  // void openInWebURLtest(
  //     BuildContext context, String urlArgs, String type) async {
  //   await ref.read(fundProvider).fetchHstoken(context);

  //   // debugPrint(
  //   //     '$urlArgs  ==== ${pref.clientId} =====  ${ref.read(fundProvider).fundHstoken!.hstk}');
  //   String url =
  //       'http://192.168.5.148:8080/${urlArgs}?uid=${pref.clientId}&token=${pref.token}&type=${type}&src=mobileapp';
  //   debugPrint('weburl ::: $url');
  //   Navigator.push(
  //     context,
  //     PageRouteBuilder(
  //       pageBuilder: (_, __, ___) => InAppWebViewScreen(url: url),
  //       transitionsBuilder: (_, animation, __, child) {
  //         return SlideTransition(
  //           position: Tween<Offset>(
  //             begin: const Offset(-1.0, 0.0),
  //             end: Offset.zero,
  //           ).animate(animation),
  //           child: child,
  //         );
  //       },
  //     ),
  //   );
  // }

  List<PendingStatus> _pendingStatusList = [];
  List<PendingStatus> get pendingStatusList => _pendingStatusList;
  
  Future fetchPendingstatus() async {
    try {
      PendingStatus response = await api.fetchPendingstatusApi();
      _pendingStatusList = [response];
      notifyListeners();
    } 
    catch (e) {
      debugPrint("error fetchpendig :::: ${e}");
    } finally {
      notifyListeners();
    }
    }
    bool _cancelpendingloader = false;
    bool get cancelpendingloader => _cancelpendingloader;
    cancelPendingloader(bool value){
      _cancelpendingloader = value;
      print("cancelpendingloader :::: ${_cancelpendingloader}");
      notifyListeners();
    }

  Future cancelPendingStatus(String type, BuildContext context) async {
    try {
      cancelPendingloader(true);
      String? fileid = await api.fetctfileidapi(type);
      String response = await api.cancelPendingStatusApi(type, fileid ?? "");
      Navigator.pop(context);
      if(response == "Cancel Success"){
      _pendingStatusList = [];
      fetchPendingstatus();
      successMessage(context, "Esign Cancellation Success");
      notifyListeners();
      }else{
        warningMessage(context, "Esign Cancellation Failed");
      }
    } catch (e) {
      debugPrint("error cancel pending status :::: ${e}");
      warningMessage(context, "Something Went Wrong");
    } finally {
      cancelPendingloader(false);
      notifyListeners();
    }
  }

  Future fetchClientProfileAllDetails() async {
    try {
      _clientAllDetails = await api.getClientProfileAllDetailsApi();
    } catch (e) {}
    notifyListeners();
  }

  Future emaileotpfun(String newEmail, String oldEmail, String clientName,
      String dpcode) async {
    try {
      String response = await api.sendOTPtoChangeEmailApi(
          newEmail, oldEmail, clientName, dpcode);
      // _mobileotpo = response;
      notifyListeners();

      print("emaileotpfun ${response}");
    } catch (e) {
    } finally {
      notifyListeners();
    }
  }

  Future emailotpres(String otpres, String newemail) async {
    try {
      String response = await api.verifyOTPtoChangeEmailApi(otpres, newemail);
      // _emilotpres = response;
      notifyListeners();

      print("object ${response}");
    } catch (e) {
    } finally {
      notifyListeners();
    }
  }

  Future mobileotpfun(
      String newmo, String clemail, String oldmobilmo, fulldataprf) async {
    try {
      String response =
          await api.mobileotpapifun(newmo, clemail, oldmobilmo, fulldataprf);
      // _mobileotpo = response;
      notifyListeners();

      print("mobileotpfun ${response}");
    } catch (e) {
      // debugPrint("$e");
    } finally {
      notifyListeners();
    }
  }

  Future mobileotpverify(String newmo, String mbotp, fulldataprf) async {
    try {
      String response = await api.mobileotpverify(newmo, mbotp, fulldataprf);
      // _mobileotpverres = response;
      notifyListeners();

      print("mobileotpverify ${response}");
    } catch (e) {
      // debugPrint("$e");
    } finally {
      notifyListeners();
    }
  }

  Future addmanbankverf(String newadd, String pincoderes, String dist,
      String state, String county, String profty, fulldataprf, filepath) async {
    try {
      String response = await api.manaddbankapi(newadd, pincoderes, dist, state,
          county, profty, fulldataprf, filepath);
      // _manualaddbank = response;
      notifyListeners();

      print("addmanbankverf ${response}");
    } catch (e) {
      // debugPrint("$e");
    } finally {
      notifyListeners();
    }
  }

  Future ddpiledgerbaapi() async {
    try {
      String response = await api.ledgerbalanceapi();
      // _ddpiledgerbalace = response;
      notifyListeners();

      print("ddpiledgerbaapi ${response}");
    } catch (e) {
      // debugPrint("$e");
    } finally {
      notifyListeners();
    }
  }

  Future ddpifinalstep(fulldataprf) async {
    try {
      String response = await api.finalddpisubmitapi(fulldataprf);
      // _ddpiesignfile = response;
      notifyListeners();

      print("ddpifinalstep ${response}");
    } catch (e) {
      // debugPrint("$e");
    } finally {
      notifyListeners();
    }
  }

  Future mtfenbprovi(fulldataprf) async {
    try {
      String response = await api.mtfenabapipage(fulldataprf);
      // _mtfenabrespoce = response;
      notifyListeners();

      print("mtfenbprovi ${response}");
    } catch (e) {
      // debugPrint("$e");
    } finally {
      notifyListeners();
    }
  }

  Future incomeotpsenpro(mobilno) async {
    try {
      String response = await api.incomeotesendapi(mobilno);
      // _imcomeptsenres = response;
      notifyListeners();

      print("incomeotpsenpro ${response}");
    } catch (e) {
      // debugPrint("$e");
    } finally {
      notifyListeners();
    }
  }

  Future incomeotpverpro(otpno, fulldataprf, chipval, file, proftye) async {
    try {
      String response = await api.incomeotpverfapi(
          otpno, fulldataprf, chipval, file, proftye);
      // _incomeotpverres = response;
      notifyListeners();

      print("incomeotpverpro ${response}");
    } catch (e) {
      // debugPrint("$e");
    } finally {
      notifyListeners();
    }
  }

  Future incomupprov(
      fulldataprf, String chipval, String filepath, String proftye) async {
    try {
      String response =
          await api.incomeupdateaapi(fulldataprf, chipval, filepath, proftye);
      // _incomupdaqres = response;
      notifyListeners();

      print("incomupprov ${response}");
    } catch (e) {
      // debugPrint("$e");
    } finally {
      notifyListeners();
    }
  }

  Future ifscapiporov(String ifsccode) async {
    try {
      String response = await api.ifsccodecheckapi(ifsccode);
      // _ifsccoderess = response;
      notifyListeners();

      print("ifscapiporov ${response}");
    } catch (e) {
      // debugPrint("$e");
    } finally {
      notifyListeners();
    }
  }

  Future addbankprovui(
      String banacc,
      String bankifc,
      String filepath,
      String profftype,
      String setpri,
      String accty,
      fulldataprf,
      bankdata) async {
    try {
      String response = await api.addbankapi(banacc, bankifc, filepath,
          profftype, setpri, accty, fulldataprf, bankdata);
      // _banksumbres = response;
      notifyListeners();

      print("addbankprovui ${response}");
    } catch (e) {
      // debugPrint("$e");
    } finally {
      notifyListeners();
    }
  }

  Future addfamilaccprov(String menid, String relation, String menpan,
      String mobilno, fulldataprf) async {
    try {
      String response = await api.addfamilaccapi(
          menid, relation, menpan, mobilno, fulldataprf);
      // _banksumbres = response;
      notifyListeners();

      print("addfamilaccprov ${response}");
    } catch (e) {
      // debugPrint("$e");
    } finally {
      notifyListeners();
    }
  }

  Future closeaccnalprov(String resaqon, fulldataprf) async {
    try {
      dynamic _chackaccbalace = await api.closeacbalapi(resaqon, fulldataprf);
      notifyListeners();
      print("_banksumbres ${_chackaccbalace}");
    } catch (e) {
      debugPrint("$e");
    } finally {
      notifyListeners();
    }
  }

  Future closeaccfinalspro(String dpid, String boid, String filepath,
      String reason, fulldataprf, bankdata) async {
    try {
      dynamic _chackaccClosureResp = await api.acccloserapi(
          dpid, boid, filepath, reason, fulldataprf, bankdata);
      notifyListeners();
      print("_banksumbres ${_chackaccClosureResp}");
    } catch (e) {
      debugPrint("$e");
    } finally {
      notifyListeners();
    }
  }
}
