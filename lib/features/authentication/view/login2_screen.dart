import 'package:fmecg_mobile/components/submit_button.dart';
import 'package:fmecg_mobile/constants/color_constant.dart';
import 'package:fmecg_mobile/features/authentication/bloc/authentication_bloc.dart';
import 'package:fmecg_mobile/features/authentication/bloc/authentication_event.dart';
import 'package:fmecg_mobile/screens/auth_screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Login2Screen extends StatefulWidget {
  const Login2Screen({Key? key}) : super(key: key);

  @override
  State<Login2Screen> createState() => _Login2ScreenState();
}

class _Login2ScreenState extends State<Login2Screen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  FocusNode focusNodeEmail = FocusNode();
  FocusNode focusNodePassword = FocusNode();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool loginProcess = false;
  bool showLoginError = true; // Thêm biến showLoginError và khởi tạo là false

  final paddingLoginHorizontal30 = const EdgeInsets.symmetric(horizontal: 30);

  bool _obscureText = true;

  bool isValidEmail(String emailTyped) {
    // regular expression: example@email.vn (not begin with .): test@vais.vn
    final emailRegExp = RegExp(r"^[a-zA-Z0-9][a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegExp.hasMatch(emailTyped);
  }

  bool isValidPassword(String passwordTyped) {
    // regular expression: 8 digit +:Test1234
    final passwordRegExp = RegExp(r'\S{8,}');
    return passwordRegExp.hasMatch(passwordTyped);
  }

  @override
  void initState() {
    super.initState();
  }

  Widget _formLoginUser() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: ColorConstant.quinary, borderRadius: BorderRadius.circular(12)),
            margin: paddingLoginHorizontal30,
            child: TextFormField(
              controller: _emailController,
              focusNode: focusNodeEmail,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Email",
                hintStyle: TextStyle(color: ColorConstant.quaternary, fontWeight: FontWeight.bold, fontSize: 16),
                contentPadding: const EdgeInsets.only(left: 20, top: 20, bottom: 20),
              ),
              style: const TextStyle(color: Colors.black),
              validator: (value) {
                if (!isValidEmail(value!)) {
                  return "Enter valid email: example@email.com";
                }
                if (value.isEmpty) {
                  return "Email can't left empty";
                }
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(color: ColorConstant.quinary, borderRadius: BorderRadius.circular(12)),
            margin: paddingLoginHorizontal30,
            child: TextFormField(
              obscureText: _obscureText,
              controller: _passwordController,
              focusNode: focusNodePassword,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Password",
                hintStyle: TextStyle(color: ColorConstant.quaternary, fontWeight: FontWeight.bold, fontSize: 16),
                contentPadding: const EdgeInsets.only(left: 20, top: 20, bottom: 20),
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  child: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.black),
                ),
              ),
              style: const TextStyle(color: Colors.black),
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
          if (!showLoginError)
            // Display error message if needed
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text('Tài khoản hoặc mật khẩu không đúng', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    focusNodeEmail.dispose();
    focusNodePassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // logo
                const Image(image: AssetImage("assets/images/fm_ecg.png"), height: 100),
                // welcome
                Text(
                  "Welcome to fmECG!",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: ColorConstant.quaternary),
                ),
                // 2 input
                const SizedBox(height: 80),
                _formLoginUser(),

                // forgot password
                const SizedBox(height: 15),
                Container(
                  margin: paddingLoginHorizontal30,
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Forgot password?",
                    style: TextStyle(color: ColorConstant.primary, fontWeight: FontWeight.bold),
                  ),
                ),

                // button login
                const SizedBox(height: 50),
                Container(
                  margin: paddingLoginHorizontal30,
                  child:
                      loginProcess
                          ? CircularProgressIndicator(color: ColorConstant.primary)
                          : SubmitButton(
                            onTap:
                                () => context.read<AuthenticationBloc>().add(
                                  LogInRequest(email: _emailController.text, password: _passwordController.text),
                                ),
                            text: "Login",
                          ),
                ),

                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?", style: TextStyle(color: Colors.black)),
                    TextButton(
                      onPressed:
                          () =>
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                      child: Text(
                        "  Sign up",
                        style: TextStyle(color: ColorConstant.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
