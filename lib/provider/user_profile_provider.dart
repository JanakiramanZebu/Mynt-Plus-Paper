import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mynt_plus/utils/overlay_manager.dart';
import '../api/core/api_export.dart';
import '../locator/constant.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';
import '../models/profile_model/algo_strategy_model.dart';
import '../models/profile_model/create_algo_strategy_request_model.dart';
import 'package:file_picker/file_picker.dart';
import '../models/profile_model/client_detail_model.dart';
import '../models/profile_model/user_detail_model.dart';
import '../res/res.dart';
import '../routes/route_names.dart';
import '../sharedWidget/snack_bar.dart';
import '../utils/image_utils.dart';
import 'auth_provider.dart';
import 'core/default_change_notifier.dart';
import 'index_list_provider.dart';
import 'shocase_provider.dart';
import '../models/profile_model/qr_login_res.dart';
import 'dart:io';

final userProfileProvider =
    ChangeNotifierProvider((ref) => UserProfileProvider(ref));

class UserProfileProvider extends DefaultChangeNotifier {
  final api = locator<ApiExporter>();
  final Preferences pref = locator<Preferences>();
  final Ref ref;

  UserDetailModel? _userDetailModel;
  UserDetailModel? get userDetailModel => _userDetailModel;

  QrLoginResponces? _qrLoginesponces;
  QrLoginResponces? get qrloginres => _qrLoginesponces;

  final FToast _fToast = FToast();
  FToast get fToast => _fToast;

  List _settingMenu = [];
  List get settingmenu => _settingMenu;

  final List _socialMedaiIcons = [
    {"icon": assets.facebook, "link": "https://www.facebook.com/zebuetrade/"},
    {"icon": assets.twitterX, "link": "https://twitter.com/zebuetrade?lang=en"},
    {
      "icon": assets.youtube,
      "link": "https://www.youtube.com/channel/UCKbEVG1fH1TwkNDe6OM-zxg"
    },
    {"icon": assets.insta, "link": "https://www.instagram.com/zebu_official/"},
    {"icon": assets.pintrest, "link": "https://in.pinterest.com/ZebuMarketing/"}
  ];
  List get socialMedaiIcons => _socialMedaiIcons;

  List _profileMenu = [];

  final List _accountMenu = [
    {"title": "Personal Info", "trailing": "assets/profile/greater_arrow.svg"},
    {"title": "Bank", "trailing": "assets/profile/greater_arrow.svg"},
    {"title": "Demat", "trailing": "assets/profile/greater_arrow.svg"},
    {
      "title": "Trading Preference",
      "trailing": "assets/profile/greater_arrow.svg"
    },
    {
      "title": "Margin Trading Facility (MTF)",
      "trailing": "assets/profile/greater_arrow.svg"
    },
    {"title": "Annual Income", "trailing": "assets/profile/greater_arrow.svg"},
    {"title": "Nominee", "trailing": "assets/profile/greater_arrow.svg"},
    {"title": "Family Account", "trailing": "assets/profile/greater_arrow.svg"},
    {"title": "Closure", "trailing": "assets/profile/greater_arrow.svg"},
    {"title": "Form Download", "trailing": "assets/profile/greater_arrow.svg"},
  ];

  final List _reporttMenu = [
    {
      "Subtitle": "P&L Insights",
      "title": "Access P&L reports by date for better insights.",
      "trailing": "assets/profile/greater_arrow.svg"
    },
    {
      "title": "View & Track Financial Transactions",
      "Subtitle": "Ledger",
      "trailing": "assets/profile/greater_arrow.svg"
    },
    {
      "title": "Monitor Your Investment Portfolio",
      "Subtitle": "Holdings",
      "trailing": "assets/profile/greater_arrow.svg"
    },
    {
      "title": "Track Open & Closed Trading Positions",
      "Subtitle": "Positions - (Beta)",
      // "trailing": "assets/profile/ex-link.svg"
      "trailing": "assets/profile/greater_arrow.svg"
    },
    // {
    //   "title": "Positions - (Beta)",
    //   "trailing": "assets/profile/greater_arrow.svg"
    // },
    {
      "title": "Analyze Trading Profit & Loss",
      "Subtitle": "Profit and Loss",
      "trailing": "assets/profile/greater_arrow.svg"
    },

    {
      "title": "Generate Tax Reports & P&L for Filing",
      "Subtitle": "Tax P&L",
      "trailing": "assets/profile/greater_arrow.svg"
    },
    {
      "title": "Access Trade History & Contract Notes",
      "Subtitle": "Tradebook/Contract",
      "trailing": "assets/profile/greater_arrow.svg"
    },
    {
      "title": "Download reports as PDFs for easy access",
      "Subtitle": "Downloads",
      "trailing": "assets/profile/greater_arrow.svg"
    },
    // cop action
    // {
    //   "title": "View & Manage Corporate Announcements",
    //   "Subtitle": "Corporate Action",
    //   "trailing": "assets/profile/greater_arrow.svg"
    // },
    {
      "title": "View & Manage Corporate Announcements",
      "Subtitle": "CA Events",
      "trailing": "assets/profile/greater_arrow.svg"
    },
    {
      "title": "Manage Pledge & Unpledged Securities",
      "Subtitle": "Pledge & Unpledge",
      "trailing": "assets/profile/greater_arrow.svg"
    },

    // {"title": "Pledge & Unpledge", "trailing": "assets/profile/greater_arrow.svg"}
  ];

  List get profileMenu => _profileMenu;
  List get accountMenu => _accountMenu;
  List get reporttMenu => _reporttMenu;

  ClientDetailModel? _clientDetailModel;
  ClientDetailModel? get clientDetailModel => _clientDetailModel;

  List<AlgoStrategyModel> _algoStrategies = [];
  List<AlgoStrategyModel> get algoStrategies => _algoStrategies;

  // Create Algo Strategy Form Management
  final _formKey = GlobalKey<FormState>();
  final _algorithmNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _strategyLogicController = TextEditingController();
  
  String? _selectedAlgorithmType;
  String? _selectedCategory;
  String? _selectedRiskLevel = 'Low';
  bool _hasAttemptedSubmit = false;
  String? _selectedFileName;
  PlatformFile? _selectedFile;
  bool _acceptTerms = false;
  bool _isEditMode = false;

  // Getters for form state
  GlobalKey<FormState> get formKey => _formKey;
  TextEditingController get algorithmNameController => _algorithmNameController;
  TextEditingController get descriptionController => _descriptionController;
  TextEditingController get strategyLogicController => _strategyLogicController;
  String? get selectedAlgorithmType => _selectedAlgorithmType;
  String? get selectedCategory => _selectedCategory;
  String? get selectedRiskLevel => _selectedRiskLevel;
  bool get hasAttemptedSubmit => _hasAttemptedSubmit;
  String? get selectedFileName => _selectedFileName;
  PlatformFile? get selectedFile => _selectedFile;
  bool get acceptTerms => _acceptTerms;
  bool get isEditMode => _isEditMode;

  // Form constants
  final List<String> algorithmTypes = ['Python', 'Pine Script', 'API-based'];
  final List<String> categories = [
    'Trend Following',
    'Mean Reversion', 
    'Momentum',
    'Breakout',
    'Oscillator-based',
    'Options Strategy',
    'Statistical Arbitrage',
    'Other'
  ];
  final List<String> riskLevels = ['Low', 'Medium', 'High'];

  UserProfileProvider(this.ref);

  bool _userloader = false;
  bool get userloader => _userloader;

  bool _showchartof = false;
  bool get showchartof => _showchartof;

  bool _onloadshowchartof = false;
  bool get onloadshowchartof => _onloadshowchartof;

  Key _webViewKey = UniqueKey();
  Key get webViewKey => _webViewKey;

  setChartdialog(bool value) {
    _showchartof = value;
    notifyListeners();
  }

  setonloadChartdialog(bool value) {
    if (value == true && !_onloadshowchartof) {
      _webViewKey = UniqueKey();
    }
    _onloadshowchartof = value;
    notifyListeners();
  }

  // Inline chart portal state (for persistent chart across navigation)
  LayerLink? _inlineChartLayerLink;
  bool _showInlineChart = false;
  Size? _inlineChartSize;

  LayerLink? get inlineChartLayerLink => _inlineChartLayerLink;
  bool get showInlineChart => _showInlineChart;
  Size? get inlineChartSize => _inlineChartSize;

  void setInlineChartTarget(LayerLink link, Size size) {
    _inlineChartLayerLink = link;
    _inlineChartSize = size;
    _showInlineChart = true;
    notifyListeners();
  }

  void hideInlineChart() {
    _showInlineChart = false;
    notifyListeners();
  }

  // Method to clear all user data when switching accounts
  void clearUserData() {
    _userDetailModel = null;
    _clientDetailModel = null;
    _showchartof = false;
    _onloadshowchartof = false;
    _userloader = false;
    _webViewKey = UniqueKey();
    _profileimage = null;
    // Clear inline chart state
    _inlineChartLayerLink = null;
    _showInlineChart = false;
    _inlineChartSize = null;
    notifyListeners();
  }

  profilePageloader(bool value) {
    _userloader = value;
    notifyListeners();
  }

  bool _profileloader = false;
  bool get profileloader => _profileloader;

  profileloaderfun(bool value) {
    _profileloader = value;
    // print("profileloader: $value");
    notifyListeners();
  }

// Fetching data from the api and stored in a variable

  Future fetchUserDetail(BuildContext context) async {
    try {
      _userDetailModel = await api.getUserDetail();

      if (_userDetailModel!.emsg == "Session Expired :  Invalid Session Key" &&
          _userDetailModel!.stat == "Not_Ok") {
        if (context.mounted) {
          ref.read(authProvider).ifSessionExpired(context);
        }
      }

      notifyListeners();
      return _userDetailModel;
    } catch (e) {
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "API User Detail", "Error": "$e"});
      notifyListeners();
    }
  }
// Fetching data from the api and stored in a variable

  Future fetchClientDetail(BuildContext context) async {
    try {
      _clientDetailModel = await api.getClientDetail();

      if (_clientDetailModel!.emsg ==
          "Session Expired :  Invalid Session Key") {
        ref.read(authProvider).ifSessionExpired(context);
      } else {
        ConstantName.sessCheck = true;
      }
      notifyListeners();
      return _clientDetailModel;
    } catch (e) {
      ref
          .read(indexListProvider)
          .logError
          .add({"type": "API Client Detail", "Error": "$e"});
      notifyListeners();
    } finally {}
  }

// Assinging value

  fetchsetting() {
    _settingMenu = [
      {
        "title": "API Key",
        "subTitle": "Generate & Manage API Key for Secure Trading",
        "leading": "assets/icon/key-01.svg",
        "trailing": "assets/profile/greater_arrow.svg"
      },
      {
        "title": "TOTP",
        "subTitle": "Enable Two-Factor Authentication (TOTP)",
        "leading": "assets/icon/key-01.svg",
        "trailing": "assets/profile/greater_arrow.svg"
      },
      {
        "title": "Freeze Account",
        "subTitle": "Temporarily disabling access",
        "leading": "assets/icon/key-01.svg",
        "trailing": "assets/profile/greater_arrow.svg"
      },
      {
        "title": "Change Password",
        "subTitle": "Update Your Account Password Securely",
        "leading": "assets/icon/key-01.svg",
        "trailing": "assets/profile/greater_arrow.svg"
      },
      {
        "title": "Theme",
        "subTitle": "Customize Theme & Interface Settings",
        "leading": "assets/icon/theme_icon.svg",
        "trailing": "assets/profile/greater_arrow.svg"
      },
      {
        "title": "Log",
        "subTitle": "View Account & Trading Logs",
        "leading": "assets/profile/privacy_settings.svg",
        "trailing": "assets/profile/greater_arrow.svg"
      },
      {
        "title": "Order Preference",
        "subTitle": "Set Trading Order Preferences",
        "leading": "assets/profile/privacy_settings.svg",
        "trailing": "assets/profile/greater_arrow.svg"
      },
    ];
    notifyListeners();
    return settingmenu;
  }

// Assigning value

  fetchprofilemenu() {
    _profileMenu = [
      {
        "title": "Fund",
        "subTitle": "Deposit & Withdraw Funds",
        "leading": "assets/profileimage/wallet.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": ref.read(showcaseProvide).fundcase,
        "case": "Click here to view the fund information page."
      },
      {
        "title": "My Account",
        "subTitle": "Account Settings & Profile Management",
        "leading": "assets/profileimage/user_logo.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": ref.read(showcaseProvide).accountcase,
        "case": "Click here to view the account page."
      },
      {
        "title": "Reports",
        "subTitle": "Trading & Financial Reports",
        "leading": "assets/profileimage/reports.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": ref.read(showcaseProvide).reportcase,
        "case": "Click here to view the report page."
      },
      // {
      //   "title": "Verified P&L",
      //   "subTitle": "Verified P&L",
      //   "leading": "assets/profileimage/verifiedpl.svg",
      //   "trailing": "assets/profile/greater_arrow.svg",
      //   "key": "",
      //   "case": "Click here to view the Verified P&L page."
      // },
      {
        "title": "Corporate Action",
        "subTitle": "Track Corporate Events & Actions",
        "leading": "assets/profileimage/coa_edited.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": ref.read(showcaseProvide).corporateactioncase,
        "case": "Click here to view the Corporate Action page."
      },
      // {
      //   "title": "CA Events",
      //   "subTitle": "CA Event",
      //   "leading": "assets/profileimage/caevent.svg",
      //   "trailing": "assets/profile/greater_arrow.svg",
      //   "key": "",
      //   "case": "Click here to view the Corporate Action page."
      // },
      // {
      //   "title": "Pledge & Unpledge",
      //   "subTitle": "Pledge & Unpledge",
      //   "leading": "assets/profileimage/pledge.svg",
      //   "trailing": "assets/profile/greater_arrow.svg",
      //   "key": ref.read(showcaseProvide).pledgeunpcase,
      //   "case": "Click here to view the Pledge & Unpledge page."
      // },
      {
        "title": "IPO",
        "subTitle": "Apply & Invest in IPOs",
        "leading": "assets/profileimage/reports.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": "",
        "case": "Click here to view the IPO."
      },
      {
        "title": "Mutual Fund",
        "subTitle": "Explore & Invest in Mutual Funds",
        "leading": "assets/icon/mf_icon.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": "",
        "case": "Click here to view theMutual Fund."
      },
      {
        "title": "Bonds",
        "subTitle": "Explore & Invest in Bonds",
        "leading": "assets/profileimage/reports.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": "",
        "case": "Click here to view the Log message."
      },
      {
        "title": "OptionZ",
        "subTitle": "Trade in Advanced Derivatives with OptionZ",
        "leading": "assets/profileimage/pledge.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": ref.read(showcaseProvide).pledgeunpcase,
        "case": "Click here to view the OptionZ."
      },
      //  {
      //   "title": "KRA",
      //   "subTitle": "KRA",
      //   "leading": "assets/profileimage/pledge.svg",
      //   "trailing": "assets/profile/greater_arrow.svg",
      //   "key": ref.read(showcaseProvide).pledgeunpcase,
      //   "case": "Click here to view the Pledge & Unpledge page."
      // },
      {
        "title": "Refer",
        "subTitle": "Refer your family and friends",
        "leading": "assets/profileimage/Referal_Incentive.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": ref.read(showcaseProvide).apikeycase,
        "case": "Click here to Refer your family and friends."
      },
      {
        "title": "Settings",
        "subTitle": "Manage Security, API, & Account Preferences",
        "leading": "assets/profileimage/privacy_settings.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": ref.read(showcaseProvide).logcase,
        "case": "Click here to view Settings."
      },
      {
        "title": "Rate Us",
        "subTitle": "Share Your Feedback & Experience.",
        "leading": "assets/icon/appbarIcon/star.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": ref.read(showcaseProvide).notificationcase,
        "case": "Click here to Share your experience!."
      },
      {
        "title": "Notification",
        "subTitle": "Manage Alerts & Notifications",
        "leading": "assets/icon/appbarIcon/bell.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": ref.read(showcaseProvide).notificationcase,
        "case": "Click here to view the notification."
      },
      {
        "title": "Need Help?",
        "subTitle": "Contact us, Follow us",
        "leading": "assets/profile/headphones.svg",
        "trailing": "assets/profile/greater_arrow.svg",
        "key": "",
        "case": "Click here to Contact us, Follow us."
      },
      /////
      // {
      //   "title": "Bonds",
      //   "subTitle": "Bonds",
      //   "leading": "assets/profileimage/reports.svg",
      //   "trailing": "assets/profile/greater_arrow.svg",
      //   "key": "",
      //   "case": "Click here to view the Log message."
      // },
    ];
    return profileMenu;
  }

// Fetching data from the api and stored in a variable

  Future fetchQR(BuildContext context, String unquiid, String loginfsrc,
      MobileScannerController camera) async {
    try {
      _qrLoginesponces = await api.getqr(unquiid, loginfsrc);
      if (_qrLoginesponces!.msg == "logged in") {
        successMessage(context, "${_qrLoginesponces!.msg}");
        Navigator.pop(context);
        Navigator.pop(context);
        camera.stop();
      } else {
        warningMessage(context, "${_qrLoginesponces!.emsg}");
        Navigator.pop(context);
        camera.start();
      }
    } catch (e) {
      notifyListeners();
    } finally {}
  }

// Fetching data from the api and stored in a variable

  Future fetchFreezeAc(BuildContext context) async {
    try {
      final res = await api.getaFreezeAc();
      Map data = jsonDecode(res.body);

      if (data["stat"] == "Ok") {
        await fetchBlockAc(context);
      } else {
        warningMessage(context, data["emsg"].toString());
      }
    } catch (e) {
      notifyListeners();
    } finally {}
  }

// Fetching data from the api and stored in a variable

  Future fetchBlockAc(BuildContext context) async {
    try {
      final res = await api.getaBlockAc();
      Map data = jsonDecode(res.body);

      if (data["stat"] == "Ok") {
        ConstantName.timer!.cancel();
        Future.microtask(() {
        if (kIsWeb) {
        OverlayManager.closeAll();
       }

        pref.clearClientSession();
        pref.setLogout(true);
        ref.read(indexListProvider).bottomMenu(1, context);
        ref.read(authProvider).loginMethCtrl.text =
            pref.isMobileLogin! ? pref.clientMob! : pref.clientId!;
        notifyListeners();

        Navigator.of(context).pop();
        // ref.read(websocketProvider).closeSocket();
        Future.delayed(Duration.zero, () {
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
                context, Routes.loginScreen, (route) => false);
          }
          successMessage(context, 'The Account has been deactivated');
        });
        });
      } else {
        warningMessage(context, data["emsg"].toString());
      }
    } catch (e) {
      notifyListeners();
    } finally {}
  }

  Future fetchAlgoStrategies(BuildContext context) async {
    try {
      toggleLoadingOn(true);
      print("🔍 Fetching algo strategies...");
      _algoStrategies = await api.getAlgoStrategy();
      print("📊 API Response - Number of strategies: ${_algoStrategies.length}");
      for (int i = 0; i < _algoStrategies.length; i++) {
        print("📋 Strategy $i: ${_algoStrategies[i].algorithmName} - ${_algoStrategies[i].status}");
      }
      notifyListeners();
    } catch (e) {
      print("❌ Error fetching algo strategies: $e");
      error(context, 'Failed to load algo strategies: $e');
      notifyListeners();
    } finally {
      toggleLoadingOn(false);
    }
  }

  Future createAlgoStrategy(BuildContext context, {
    required String algorithmName,
    required String algorithmType,
    required String category,
    required String riskLevel,
    required String description,
    required String strategyLogic,
    required PlatformFile file,
  }) async {
    try {
      toggleLoadingOn(true);
       const clientId = 'ZP00285'; 
      //  final codeLang = _getCodeLanguage(algorithmType);
      final requestData = CreateAlgoStrategyRequestModel(
        algorithmName: algorithmName,
        submittedBy: clientId,
        type: algorithmType,
        category: category,
        riskLevel: riskLevel,
        description: description,
        logicDescription: strategyLogic,
        codeLang: '',
      );
      
      print("Creating algo strategy: $algorithmName");
      final response = await api.createAlgoStrategy(
        requestData: requestData,
        file: file,
      );
      
      print("Algo strategy created successfully: $response");
      
      // Refresh the algo strategies list
      await fetchAlgoStrategies(context);
      
      // Clear form after successful creation
      clearForm();
      
      successMessage(context, 'Algorithm strategy created successfully!');
      
    } catch (e) {
      print("Error creating algo strategy: $e");
      print("Stack trace: ${StackTrace.current}");
      error(context, 'Failed to create algorithm strategy: $e');
    } finally {
      toggleLoadingOn(false);
    }
  }

  String? _getCodeLanguage(String algorithmType) {
    switch (algorithmType.toLowerCase()) {
      case 'python':
        return 'python';
      case 'pine script':
        return 'pinescript';
      case 'api-based':
        return 'api';
      default:
        return null;
    }
  }

  // Form Management Methods
  void setAlgorithmType(String? value) {
    _selectedAlgorithmType = value;
    notifyListeners();
  }

  void setCategory(String? value) {
    _selectedCategory = value;
    notifyListeners();
  }

  void setRiskLevel(String? value) {
    _selectedRiskLevel = value;
    notifyListeners();
  }

  void setAcceptTerms(bool value) {
    _acceptTerms = value;
    notifyListeners();
  }

  void setAttemptedSubmit(bool value) {
    _hasAttemptedSubmit = value;
    notifyListeners();
  }

  void setSelectedFile(PlatformFile file) {
    _selectedFile = file;
    _selectedFileName = file.name;
    notifyListeners();
  }

  void clearForm() {
    _algorithmNameController.clear();
    _descriptionController.clear();
    _strategyLogicController.clear();
    _selectedAlgorithmType = null;
    _selectedCategory = null;
    _selectedRiskLevel = 'Low';
    _hasAttemptedSubmit = false;
    _selectedFileName = null;
    _selectedFile = null;
    _acceptTerms = false;
    _isEditMode = false;
    notifyListeners();
  }

  void populateFormForEdit(AlgoStrategyModel strategy) {
    print("🔍 POPULATING FORM FOR EDIT:");
    print("  Algorithm Name: ${strategy.algorithmName}");
    print("  Type: ${strategy.type}");
    print("  Category: ${strategy.category}");
    print("  Risk Level (raw): ${strategy.riskLevel}");
    
    _isEditMode = true; // Set edit mode flag
    _algorithmNameController.text = strategy.algorithmName;
    _descriptionController.text = strategy.description;
    _strategyLogicController.text = strategy.logicDescription;
    _selectedAlgorithmType = strategy.type;
    _selectedCategory = strategy.category;
    // Convert risk level to proper case (e.g., "medium" -> "Medium")
    _selectedRiskLevel = _capitalizeFirstLetter(strategy.riskLevel);
    
    print("  Risk Level (converted): $_selectedRiskLevel");
    print("  Available risk levels: $riskLevels");
    
    _hasAttemptedSubmit = false;
    _selectedFileName = strategy.filePath.split('/').last ?? 'Existing file';
    _selectedFile = null; // Will need to be re-selected for update
    _acceptTerms = true; // Assume terms are accepted for existing strategy
    notifyListeners();
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  void disposeForm() {
    _algorithmNameController.dispose();
    _descriptionController.dispose();
    _strategyLogicController.dispose();
  }

  // File Selection Logic
  Future<void> selectFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['py', 'pine', 'js', 'json'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        
        // Check file size (5MB = 5 * 1024 * 1024 bytes)
        const int maxSizeInBytes = 5 * 1024 * 1024;
        
        if (file.size > maxSizeInBytes) {
          error(context, 'File size must be less than 5MB');
          return;
        }
        
        // Check file extension
        String? extension = file.extension?.toLowerCase();
        if (extension != null && ['py', 'pine', 'js', 'json'].contains(extension)) {
          // Verify file bytes are loaded
          if (file.bytes != null) {
            setSelectedFile(file);
            print("✅ File selected successfully with ${file.bytes!.length} bytes");
          } else {
            error(context, 'Failed to load file content. Please try again.');
          }
        } else {
          error(context, 'Please select a valid file (.py, .pine, .js, .json)');
        }
      }
    } catch (e) {
      print("💥 File selection error: $e");
      error(context, 'Error selecting file: $e');
    }
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  // Form Validation
  String? validateField(String label, String? value) {
    if (value == null || value.trim().isEmpty) {
      switch (label) {
        case 'Algorithm Name':
          return 'Algorithm name is required';
        case 'Algorithm Type':
          return 'Algorithm type is required';
        case 'Category':
          return 'Category is required';
        case 'Risk Level':
          return 'Risk level is required';
        case 'Algorithm Description':
          return 'Algorithm description is required';
        case 'Strategy Logic':
          return 'Strategy logic is required';
        default:
          return 'This field is required';
      }
    }
    if (label == 'Algorithm Name' && value.trim().length < 3) {
      return 'Algorithm name must be at least 3 characters';
    }
    return null;
  }

  bool isFormValid() {
    // In edit mode, file upload is optional
    bool fileRequired = !_isEditMode;
    
    return _formKey.currentState!.validate() && 
           _selectedRiskLevel != null && 
           (!fileRequired || _selectedFile != null) && 
           _acceptTerms;
  }

  // Submit Form
  Future<bool> submitForm(BuildContext context) async {
    setAttemptedSubmit(true);
    
    if (isFormValid()) {
      try {
        await createAlgoStrategy(
          context,
          algorithmName: _algorithmNameController.text.trim(),
          algorithmType: _selectedAlgorithmType!,
          category: _selectedCategory!,
          riskLevel: _selectedRiskLevel!,
          description: _descriptionController.text.trim(),
          strategyLogic: _strategyLogicController.text.trim(),
          file: _selectedFile!,
        );
        return true; // Success
      } catch (e) {
        return false; // Failed
      }
    }
    return false; // Form not valid
  }

  Future<void> updateAlgoStrategy(
    BuildContext context, {
    required String submissionId,
    required String algoId,
    required String algorithmName,
    required String algorithmType,
    required String category,
    required String riskLevel,
    required String description,
    required String strategyLogic,
    PlatformFile? file,
  }) async {
    try {
      toggleLoadingOn(true);
      const clientId = 'ZP00285';
      
      final requestData = CreateAlgoStrategyRequestModel(
        algorithmName: algorithmName,
        submittedBy: clientId,
        type: algorithmType,
        category: category,
        riskLevel: riskLevel,
        description: description,
        logicDescription: strategyLogic,
        codeLang: '',
      );
      
      print("Updating algo strategy: $algorithmName");
      final response = await api.updateAlgoStrategy(
        requestData: requestData,
        file: file,
        submissionId: submissionId,
        algoId: algoId,
      );
      
      print("Algo strategy updated successfully: $response");
      
      // Refresh the algo strategies list
      await fetchAlgoStrategies(context);
      
      // Clear form after successful update
      clearForm();
      
      successMessage(context, 'Algorithm strategy updated successfully!');
      
    } catch (e) {
      print("Error updating algo strategy: $e");
      print("Stack trace: ${StackTrace.current}");
      error(context, 'Failed to update algorithm strategy: $e');
    } finally {
      toggleLoadingOn(false);
    }
  }

  Future<bool> updateForm(BuildContext context, String submissionId, String algoId) async {
    print("🔍 UPDATE FORM CALLED:");
    print("  Submission ID: $submissionId");
    print("  Algo ID: $algoId");
    print("  Algorithm Name: ${_algorithmNameController.text.trim()}");
    print("  Algorithm Type: $_selectedAlgorithmType");
    print("  Category: $_selectedCategory");
    print("  Risk Level: $_selectedRiskLevel");
    print("  Description: ${_descriptionController.text.trim()}");
    print("  Strategy Logic: ${_strategyLogicController.text.trim()}");
    print("  Selected File: ${_selectedFile?.name}");
    print("  Form Valid: ${isFormValid()}");
    
    setAttemptedSubmit(true);
    
    if (isFormValid()) {
      try {
        await updateAlgoStrategy(
          context,
          submissionId: submissionId,
          algoId: algoId,
          algorithmName: _algorithmNameController.text.trim(),
          algorithmType: _selectedAlgorithmType!,
          category: _selectedCategory!,
          riskLevel: _selectedRiskLevel!,
          description: _descriptionController.text.trim(),
          strategyLogic: _strategyLogicController.text.trim(),
          file: _selectedFile, // Now optional
        );
        return true; // Success
      } catch (e) {
        print("❌ Update failed: $e");
        return false; // Failed
      }
    }
    print("❌ Form validation failed");
    return false; // Form not valid
  }

  Future<bool> deleteAlgoStrategy(BuildContext context, String submissionId, String algoId) async {
    try {
      toggleLoadingOn(true);
      
      print("Deleting algo strategy: $algoId");
      final response = await api.deleteAlgoStrategy(submissionId, algoId);
      
      print("Algo strategy deleted successfully: $response");
      
      // Refresh the algo strategies list
      await fetchAlgoStrategies(context);
      
      // Clear form after successful deletion
      clearForm();
      
      successMessage(context, 'Algorithm strategy deleted successfully!');
      
      return true; // Success
      
    } catch (e) {
      print("Error deleting algo strategy: $e");
      print("Stack trace: ${StackTrace.current}");
      error(context, 'Failed to delete algorithm strategy: $e');
      return false; // Failed
    } finally {
      toggleLoadingOn(false);
    }
  }

 bool fileSizeCheck(File file) {
  final int sizeInBytes = file.lengthSync();
  final double sizeInMb = sizeInBytes / (1024 * 1024);
  return sizeInMb <= 10; // limit 10 MB
}

  Future<void> pickImageFromGallery(BuildContext context, ImageSource source) async {
  final ImagePicker picker = ImagePicker();

  try {
    final XFile? pickedFile = await picker.pickImage(
      source: source,
      maxHeight: 1800,
      maxWidth: 1800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      File file = File(pickedFile.path);

      if (!fileSizeCheck(file)) {
        warningMessage(context, 'File size exceeds the limit of 10MB');
        return;
      } else {
        await uploadImage(context, file);
      }
    } else {
      print("No image selected");
    }
  } catch (e) {
    print("Error selecting image: $e");
  }
}


  // Method to remove profile image
  Future<void> removeProfileImage(BuildContext context) async {
    try {
      final response = await api.removeProfileImage();
      if(response.statusCode == 200){
      _profileimage = null;
      successMessage(context, 'Profile picture removed successfully');
      notifyListeners();
      }else{
        warningMessage(context, 'Failed to remove profile picture');
      }
    } catch (e) {
      print("Error removing profile image: $e");
    }
  }

  // Method to take selfie using camera
//   Future<void> takeAndUploadSelfie(BuildContext context) async {
//   try {
//     final ImagePicker picker = ImagePicker();

//     // Open camera (front by default)
//     final XFile? photo = await picker.pickImage(
//       source: ImageSource.camera,
//       imageQuality: 80,
//       preferredCameraDevice: CameraDevice.front,
//     );

//     if (photo != null) {
//       File file = File(photo.path);

//       if (!await _validateImageFile(context, file)) {
//         return;
//       }

//       await uploadImage(context, file);

//     }
//   } catch (e) {
//     if (context.mounted) {
//       warningMessage(context, 'Error taking selfie: $e');
//     }
//   }
// }

  Uint8List? _profileimage;
  Uint8List? get getprofileImage => _profileimage;

  Future<void> getProfileimage() async {
    try {
      toggleimageloader(true);
      final responseData = await api.getProfileImage();
      if (responseData != null) {
        _profileimage = responseData;
        notifyListeners();
      } else {
        _profileimage = null;
        notifyListeners();
      }
    } catch (e) {
      print("error in get profile image $e");
    } finally {
      toggleimageloader(false);
    }
  }

  bool _imageloader = false;
  bool get imageLoader => _imageloader;

  toggleimageloader(bool value) {
    _imageloader = value;
    notifyListeners();
  }

  // Method to upload image to API
  Future<void> uploadImage(BuildContext context, File imageFile) async {
    try {
      toggleimageloader(true);

      // Fix image orientation before uploading (important for iOS photos)
      final processedImageFile = await ImageUtils.processImageForUpload(
        imageFile,
        maxWidth: 1024, // Limit width to 1024px for better performance
        maxHeight: 1024, // Limit height to 1024px for better performance
        quality: 85, // Good quality with reasonable file size
      );

      final responseData = await api.uploadImage(processedImageFile);

      if (responseData["status"] == "success") {
        successMessage(context, 'Profile image updated successfully!');
        _profileimage = await api.getProfileImage();
        notifyListeners();
      } else {
        warningMessage(context,
            'Failed to update image: ${responseData.statusCode} - $responseData');
      }
    } catch (e) {
      print("error in upload image $e");
    } finally {
      toggleimageloader(false);
    }
  }

  /// Web-compatible: pick image using file_picker and upload bytes
  Future<void> pickAndUploadImageWeb(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes == null) return;

        // Check file size (10MB limit)
        if (file.size > 10 * 1024 * 1024) {
          warningMessage(context, 'File size exceeds the limit of 10MB');
          return;
        }

        toggleimageloader(true);
        final responseData = await api.uploadImageBytes(
          file.bytes!,
          file.name,
        );

        if (responseData["status"] == "success") {
          successMessage(context, 'Profile image updated successfully!');
          _profileimage = await api.getProfileImage();
          notifyListeners();
        } else {
          warningMessage(context, 'Failed to update image');
        }
      }
    } catch (e) {
      print("error in web upload image $e");
    } finally {
      toggleimageloader(false);
    }
  }

}
