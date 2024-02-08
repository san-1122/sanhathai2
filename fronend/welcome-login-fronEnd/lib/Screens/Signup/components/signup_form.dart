import 'package:flutter/material.dart';
import '../../../components/already_have_an_account_acheck.dart';
import '../../../constants.dart';
import '../../Login/login_screen.dart';
import '../../../api_provider.dart';
import 'dart:async';
import 'dart:convert';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});
  @override
  _SignUpForm createState() => _SignUpForm();
}


class _SignUpForm extends State<SignUpForm> {
  final _registerkey = GlobalKey<FormState>();
  ApiProvider apiProvider = ApiProvider();
  TextEditingController _ctlEmail = TextEditingController();
  TextEditingController _ctlPassword = TextEditingController();
  TextEditingController _ctlFullname = TextEditingController();


  Future<void> doRegister_this() async {
    if (_registerkey.currentState!.validate()) {
      try {
        var rs = await apiProvider.doRegister(_ctlEmail.text, _ctlPassword.text, _ctlFullname.text);
        print(rs.statusCode); // Print status code for debugging
        print(rs.body); // Print response body for debugging
        if (rs.statusCode == 200) {
          var isRes = jsonDecode(rs.body);
          print(isRes);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const LoginScreen();
              },
            ),
          );
        } else {
          print("Server error: ${rs.reasonPhrase}");
        }
      } catch (e) {
        print("Exception error: $e");
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _registerkey,
      child: Column(
        children: [
      Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
        child:   TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please Enter Username';
              } else {
                return null;
              }
            },
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            controller: _ctlEmail,
            onSaved: (username) {},
            decoration: const InputDecoration(
              hintText: "กรอกชื่อผู้ใช้...",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
          ),
      ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please Enter Fullname';
              } else {
                return null;
              }
            },
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            controller: _ctlFullname,
            onSaved: (fullname) {},
            decoration: const InputDecoration(
              hintText: "กรอกชื่อผู้ใช้...",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
          ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please Enter Password';
                } else {
                  return null;
                }
              },
              textInputAction: TextInputAction.done,
              obscureText: true,
              cursorColor: kPrimaryColor,
              controller: _ctlPassword,
              decoration: const InputDecoration(
                hintText: "กรอกรหัสผ่านใช้ที่คุณต้องการ",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding / 2),
          ElevatedButton(
            onPressed: () => doRegister_this(),
            child: Text("สมัครสมาชิก".toUpperCase()),
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            login: false,
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const LoginScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}