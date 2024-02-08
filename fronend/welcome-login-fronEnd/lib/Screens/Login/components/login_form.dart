import 'package:flutter/material.dart';
import '../../../components/already_have_an_account_acheck.dart';
import '../../../constants.dart';
import '../../Signup/signup_screen.dart';
import '../../Welcome_login/welcome_screen.dart';
import '../../../api_provider.dart';
import 'dart:async';
import 'dart:convert';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});
  @override
  _LoginForm createState() => _LoginForm();
}

class _LoginForm extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _ctlEmail = TextEditingController();
  TextEditingController _ctlPassword = TextEditingController();

  ApiProvider apiProvider = ApiProvider();
  Future doLogin() async {
    if (_formKey.currentState!.validate()) {
      try {
        var rs = await apiProvider.doLogin(_ctlEmail.text, _ctlPassword.text);
        if (rs.statusCode == 200) {
          // debug
          // print(rs.body);
          var isRes = jsonDecode(rs.body);
          print(isRes);
          if (isRes['status'] == "ok") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const WelcomeScreen();
                },
              ),
            );
          }
        } else {
          print("server error");
        }
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
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
            onSaved: (email) {},
            decoration: const InputDecoration(
              hintText: "กรอกชื่อผู้ใช้...",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
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
                hintText: "กรอกรหัสผ่าน....",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          ElevatedButton(
            onPressed: () => doLogin(),
            child: Text(
              "เข้าสู่ระบบ".toUpperCase(),
            ),
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const SignUpScreen();
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
