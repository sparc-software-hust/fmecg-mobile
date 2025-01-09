import 'package:fmecg_mobile/screens/home_screen.dart';
import 'package:fmecg_mobile/screens/login_screen/sign_up_screen.dart';
import 'package:fmecg_mobile/screens/main_screen.dart';
import 'package:fmecg_mobile/screens/new_screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:async';
import '../../providers/auth_provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  final _formKey = GlobalKey<FormState>();

  bool isValidEmail(String emailTyped) {
    // regular expression: example@email.vn (not begin with .): test@vais.vn
    final emailRegExp =
        RegExp(r"^[a-zA-Z0-9][a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegExp.hasMatch(emailTyped);
  }

  bool isValidPassword(String passwordTyped) {
    // regular expression: 8 digit +:Test1234
    final passwordRegExp = RegExp(r'\S{8,}');
    return passwordRegExp.hasMatch(passwordTyped);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset("assets/logo/fmECG_branding.png"),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text("Welcome",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    )),
                const Text(
                  "To fmECG!",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: size.height * 0.1,
                          left: size.width * 0.05,
                          right: size.width * 0.05,
                        ),
                        child: TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintStyle: const TextStyle(color: Colors.grey),
                              label: const Text("Phone number or email"),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0)),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (!isValidEmail(value!)) {
                                return "Enter valid email: example@email.com";
                              }
                              if (value.isEmpty) {
                                return "Email can't left empty";
                              }
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: size.height * 0.01,
                          left: size.width * 0.05,
                          right: size.width * 0.05,
                        ),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            label: const Text("Password"),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                              child: Icon(_obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                            ),
                          ),
                          validator: (value) {
                            if (!isValidPassword(value!)) {
                              return "Enter valid password: at least 8 digit";
                            }
                            if (value.isEmpty) {
                              return "Password can't left empty";
                            }
                            return null;
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: size.width * 0.6, bottom: size.height * 0.04),
                        child: TextButton(
                            onPressed: () {},
                            child: Text(
                              "Forgot password ?",
                              style: TextStyle(
                                color: Colors.blue.shade700,
                              ),
                            )),
                      ),
                      Center(
                        child: Container(
                          margin: EdgeInsets.only(
                              top: size.height * 0.02,
                              bottom: size.height * 0.02),
                          height: size.height * 0.08,
                          child: ElevatedButton(
                            onPressed: authProvider.isLoading
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      await authProvider.login(
                                        _emailController.text,
                                        _passwordController.text,
                                      );
                                    }
                                    if (authProvider.token.isNotEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Login successful!'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );

                                      Future.delayed(const Duration(seconds: 2),
                                          () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const MainScreen()),
                                        );
                                      });
                                    }
                                  },
                            child: authProvider.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Log in",
                                    style: TextStyle(color: Colors.black),
                                  ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll<Color>(
                                  Colors.blue.shade700),
                              padding:
                                  MaterialStatePropertyAll<EdgeInsetsGeometry>(
                                EdgeInsets.symmetric(
                                  horizontal: size.width * 0.39,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(color: Colors.grey),
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            const SignUpScreen()));
                              },
                              child: const Text(
                                "Sign up",
                                style: TextStyle(color: Colors.blue),
                              ))
                        ],
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Padding(
                      padding: EdgeInsets.only(
                          top: size.height * 0.02, bottom: size.height * 0.02),
                      child: const Text("Or continue with")),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: null,
                      child: SizedBox(
                          height: size.height * 0.06,
                          width: size.width * 0.3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/logo/google.png",
                                height: size.height * 0.03,
                              ),
                              const Text(
                                "  Google",
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          )),
                    ),
                    SizedBox(
                      height: size.height * 0.06,
                      width: size.width * 0.05,
                    ),
                    ElevatedButton(
                      onPressed: null,
                      child: SizedBox(
                          height: size.height * 0.06,
                          width: size.width * 0.3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/logo/facebook.png",
                                height: size.height * 0.03,
                              ),
                              const Text(
                                "  Facebook",
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          )),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
