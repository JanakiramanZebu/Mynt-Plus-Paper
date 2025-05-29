import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/core/api_export.dart';
import '../locator/constant.dart';
import '../locator/locator.dart';
import '../locator/preference.dart';
import '../models/auth_model/forgot_pass_model.dart';
import '../models/auth_model/mynt_changepass_model.dart';
import '../routes/route_names.dart';
import '../sharedWidget/snack_bar.dart';
import 'auth_provider.dart';
import 'core/default_change_notifier.dart';
import 'index_list_provider.dart';

final changePasswordProvider =
    ChangeNotifierProvider((ref) => ChangePasswordProvider(ref));

class ChangePasswordProvider extends DefaultChangeNotifier {
  final Ref ref;
  final api = locator<ApiExporter>();
  final Preferences pref = locator<Preferences>();

  //  Text field controller for Change password

  final TextEditingController oldPassword = TextEditingController();
  final TextEditingController newPassword = TextEditingController();
  final TextEditingController forGetloginMethCtrl = TextEditingController();

  final TextEditingController userIdController = TextEditingController();

  bool get isMobileForgetpass => _isMobileForgetpass;
  bool _isMobileForgetpass = false;

  bool _isDisableforgetbtn = true;
  bool get isDisableforgetbtn => _isDisableforgetbtn;
  bool _hideoldpassword = true;
  bool _hidenewpassword = true;
  bool get hideoldpassword => _hideoldpassword;
  bool get hidenewpassword => _hidenewpassword;

  bool _isDisableChangepassbtn = true;
  bool get isDisableChangepassbtn => _isDisableChangepassbtn;

  String? userIdChangepassError,
      oldPasswordError,
      newPasswordError,
      forgetpassError;

  ForgetPasswordModel? _forgetPasswordModel;
  ForgetPasswordModel? get changePass => _forgetPasswordModel;
  MyntChangePasswordModel? _changepasswordmodel;
  MyntChangePasswordModel? get changepasswordmodel => _changepasswordmodel;

// Clear all text field values form change password screen
  void clearTextField() {
    oldPassword.clear();
    newPassword.clear();

    forGetloginMethCtrl.clear();
    notifyListeners();
  }

// Clear change pass validation error
  void clearError() {
    userIdChangepassError = null;
    oldPasswordError = null;
    newPasswordError = null;

    forgetpassError = null;
    notifyListeners();
  }

  changePassMethod() {
    _isDisableChangepassbtn = true;
    clearError();
    clearTextField();
    notifyListeners();
  }

  forgetMethod() {
    _isMobileForgetpass = !_isMobileForgetpass;
    _isDisableforgetbtn = true;

    clearError();
    clearTextField();
    notifyListeners();
  }

// Validating Forgot password

  bool validateForgetpassWord() {
    clearError();
    if (forGetloginMethCtrl.text.trim().isEmpty) {
      forgetpassError = "Your client id / mobile is required";
    }
    return forgetpassError == null;
  }

// If Forgot pass validation is successful, activate the  button.

  activateFrogetbtn() {
    if (validateForgetpassWord()) {
      _isDisableforgetbtn = false;
    } else {
      _isDisableforgetbtn = true;
    }
    notifyListeners();
  }

// Call this method while clicking if the Forgot pass validation process is successful.
  submitForgetPassword(BuildContext context) {
    if (validateForgetpassWord()) {
      fetchForgetPassword(
          // _isMobileForgetpass ? "clientid" : "mobile",
          forGetloginMethCtrl.text,
          forGetloginMethCtrl.text.toUpperCase(),
          context);
    }
  }

// If Change pass validation is successful, activate the button.

  activateChangePass() {
    if (validateChangePassword()) {
      _isDisableChangepassbtn = false;
    } else {
      _isDisableChangepassbtn = true;
    }

    print(isDisableChangepassbtn);
    notifyListeners();
  }

// Show / Hide password text values

  hiddeoldpasswords() {
    _hideoldpassword = !_hideoldpassword;
    notifyListeners();
  }

  hiddenewpasswords() {
    _hidenewpassword = !_hidenewpassword;
    notifyListeners();
  }

// Validating Change Pass
  bool validateChangePassword() {
    clearError();
    if (userIdController.text.trim().isEmpty) {
      userIdChangepassError = "Please enter username";
    }

    if (oldPassword.text.trim().isEmpty) {
      oldPasswordError = "Please enter the Old Password";
    }
    if (newPassword.text.trim().isEmpty) {
      newPasswordError = "Please enter the New Password";
    } else if (!RegExp(r'^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[#$-*@]).{7,}$')
        .hasMatch(newPassword.text)) {
      newPasswordError = "Please Enter the Valid Password";
    }

    notifyListeners();
    return userIdChangepassError == null &&
        oldPasswordError == null &&
        newPasswordError == null;
  }

// Fetching data from the api and stored in a variable
  fetchForgetPassword(String field, String value, BuildContext context) async {
    try {
      toggleLoadingOn(true);
      _forgetPasswordModel = await api.getForgetPassword(field, value);
      if (_forgetPasswordModel!.stat == "Ok") {
        ConstantName.sessCheck = true;
        ScaffoldMessenger.of(context).showSnackBar(successMessage(
            context, 'New Password is Sended Through Email/Sms'));

        userIdController.text = '${_forgetPasswordModel!.clientid}';

        Future.delayed(const Duration(seconds: 2), () {
          forgetMethod();
          clearError();
          Navigator.pushNamed(context, Routes.changePass, arguments: "No");
        });
      } else if (_forgetPasswordModel!.stat == "Not_Ok") {
        ScaffoldMessenger.of(context)
            .showSnackBar(warningMessage(context, _forgetPasswordModel!.emsg!));
      } else if (_forgetPasswordModel!.emsg ==
          "Session Expired :  Invalid Session Key") {
        ref.read(authProvider).ifSessionExpired(context);
      }

      notifyListeners();
    } catch (e) {
      ref.read(indexListProvider).logError.add({"type": "API", "Error": "$e"});
      notifyListeners();
    } finally {
      toggleLoadingOn(false);
    }
  }
// Call this method while clicking if the Change pass validation process is successful.

  submitChangePass(BuildContext context) {
    if (validateChangePassword()) {
      fetchChangePassword(userIdController.text.toUpperCase(), oldPassword.text,
          newPassword.text, context);
    }
  }

// Fetching data from the api and stored in a variable
  fetchChangePassword(String userId, String oldpassword, String password,
      BuildContext context) async {
    try {
      toggleLoadingOn(true);
      _changepasswordmodel =
          await api.getChangePasswordProfile(userId, oldpassword, password);
      if (_changepasswordmodel!.stat == "Ok") {
        ConstantName.sessCheck = true;
        ref.read(authProvider).clearTextField();

        ScaffoldMessenger.of(context).showSnackBar(
            successMessage(context, '${_changepasswordmodel!.dmsg}'));
        pref.setHideLoginOptBtn(false);
        ref.read(authProvider).loginMethCtrl.text = pref.clientId!;
        pref.setMobileLogin(false);

        Future.delayed(const Duration(seconds: 2), () {
          changePassMethod();
          Navigator.pushNamedAndRemoveUntil(
              context, Routes.loginScreen, (route) => false);
        });
      } else if (_changepasswordmodel!.stat == "Not_Ok") {
        warningToaster(context,
            _changepasswordmodel!.emsg!.replaceAll("Error Occurred :", ""));
      } else if (_changepasswordmodel!.emsg ==
          "Session Expired :  Invalid Session Key") {
        ref.read(authProvider).ifSessionExpired(context);
      }

      notifyListeners();
    } catch (e) {
      ref.read(indexListProvider).logError.add({"type": "API", "Error": "$e"});
      notifyListeners();
    } finally {
      toggleLoadingOn(false);
    }
  }

  ChangePasswordProvider(this.ref);
}
