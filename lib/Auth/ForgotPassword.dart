import 'dart:convert';

import 'package:fluoro/Auth/Login.dart';
import 'package:fluoro/common/Global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => ForgotPasswordState();
}

class ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  var _resetResult = {};

  void _reset() async{
    if (_formKey.currentState?.validate() ?? false) {
      final resetResponse = await http.post(
        Uri.parse('${Global.host}/api/auth/forgot-password'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'email': _email,
        }),
      );
      setState(() {
        _resetResult = json.decode(resetResponse.body);
        _formKey.currentState!.validate();
      });

      if (resetResponse.statusCode == 200) {
        // 跳转登录页
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>
            const Login()
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.resetSuccess)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.resetFail)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(40, 20, 40, 20),
            child: Text(
                AppLocalizations.of(context)!.resetPassword,
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
                      labelText: AppLocalizations.of(context)!.email,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _email = value;
                        _resetResult = {};
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.enterEmail;
                      }
                      if (_resetResult.isNotEmpty && _resetResult["message"] == "User not found") {
                        return AppLocalizations.of(context)!.emailNotFound;
                      }
                      if (_resetResult.isNotEmpty && _resetResult["message"] == "Email send fail") {
                        return AppLocalizations.of(context)!.emaiSendFail;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _reset,
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
        ],
      ),
    );
  }
}
