import 'dart:convert';

import 'package:fluoro/Auth/Login.dart';
import 'package:fluoro/common/Global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => RegisterState();
}

class RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _username = '';
  String _password = '';
  String _passwordConfirm = '';
  String _invitationCode = '';
  var _registerResult = {};

  void _register() async{
    if (_formKey.currentState?.validate() ?? false) {
      // 这里可以添加登录逻辑
      final registerResponse = await http.post(
        Uri.parse('${Global.host}/api/auth/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'username': _username,
          'password': _password,
          "email": _email,
          "invitationCode": _invitationCode
        }),
      );
      setState(() {
        _registerResult = json.decode(registerResponse.body);
        _formKey.currentState!.validate();
      });

      if (registerResponse.statusCode == 200) {
        // 跳转登录页
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>
          const Login()
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.registerSuccess))
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.registerFail)),
        );
        print('Request failed: $_registerResult');
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
                const Login()
                ),
              );
            },
            child: Text(
              AppLocalizations.of(context)!.capitalizedSignIn,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(40, 20, 40, 20),
              child: Text(
                  AppLocalizations.of(context)!.createAccount,
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
                          _registerResult = {};
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.enterEmail;
                        }
                        if (_registerResult.isNotEmpty && _registerResult["message"] == "Wrong email format") {
                          return AppLocalizations.of(context)!.wrongEmail;
                        }
                        if (_registerResult.isNotEmpty && _registerResult["message"] == "Email already exists") {
                          return AppLocalizations.of(context)!.existsEmail;
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
                        labelText: AppLocalizations.of(context)!.username,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _username = value;
                          _registerResult = {};
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.enterUsername;
                        }
                        if (_registerResult.isNotEmpty && _registerResult["message"] == "Username is already taken") {
                          return AppLocalizations.of(context)!.takenUsername;
                        }
                        if (value.length > 20) {
                          return AppLocalizations.of(context)!.tooLongUsername;
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
                        if (value != _passwordConfirm) {
                          return AppLocalizations.of(context)!.enterTheSamePassword;
                        }
                        if (value.length < 6) {
                          return AppLocalizations.of(context)!.tooShortPassword;
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
                        labelText: AppLocalizations.of(context)!.passwordConfirm,
                      ),
                      obscureText: true,
                      onChanged: (value) {
                        setState(() {
                          _passwordConfirm = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.enterPasswordConfirm;
                        }
                        if (value != _password) {
                          return AppLocalizations.of(context)!.enterTheSamePassword;
                        }
                        if (value.length < 6) {
                          return AppLocalizations.of(context)!.tooShortPassword;
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
                        labelText: AppLocalizations.of(context)!.invitationCode,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _invitationCode = value;
                        });
                      },
                      validator: (value) {
                        if (_registerResult.isNotEmpty && _registerResult["message"] == "Invalid invitation code") {
                          return AppLocalizations.of(context)!.invalidInvitationCode;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _register,
                    child: SizedBox(
                      width: 120,
                      height: 48,
                      child: Center(
                        child: Text(AppLocalizations.of(context)!.signUp),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }

}