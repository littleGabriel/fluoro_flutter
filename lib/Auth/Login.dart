import 'dart:convert';

import 'package:fluoro/Auth/ForgotPassword.dart';
import 'package:fluoro/Auth/Register.dart';
import 'package:fluoro/Home.dart';
import 'package:fluoro/common/Global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => LoginState();
}

class LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  var _loginResult = {};

  void _login() async{
    if (_formKey.currentState?.validate() ?? false) {
      // 这里可以添加登录逻辑
      final loginResponse = await http.post(
        Uri.parse('${Global.host}/api/auth/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'username': _username,
          'password': _password,
        }),
      );
      _loginResult = json.decode(loginResponse.body);

      if (loginResponse.statusCode == 200) {
        // 跳转入主页面
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>
            Home(loginResult: _loginResult)
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.signInFail)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>
                const Register()
                ),
              );
            },
            child: Text(
              AppLocalizations.of(context)!.capitalizedSignUp,
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(40, 20, 40, 20),
            child: Text(
                AppLocalizations.of(context)!.signInWelcome,
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                )
            ),
          ),
          Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(40, 20, 40, 20),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.username,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _username = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.enterUsername;
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(40, 0, 40, 20),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.password,
                    ),
                    obscureText: true,
                    onChanged: (value) {
                      setState(() {
                        _password = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.enterPassword;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _login,
                  child: SizedBox(
                    width: 120,
                    height: 48,
                    child: Center(
                      child: Text(AppLocalizations.of(context)!.signIn),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>
                  const ForgotPassword()
                  ),
                );
              },
              style: TextButton.styleFrom(
                // 将水波纹颜色设置为透明
                overlayColor: Colors.transparent,
              ),
              child: Text(AppLocalizations.of(context)!.forgotPassword),
            ),
          )

        ],
      ),
    );
  }
}
