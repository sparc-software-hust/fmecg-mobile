import 'package:fmecg_mobile/components/submit_button.dart';
import 'package:fmecg_mobile/generated/l10n.dart';
import 'package:fmecg_mobile/providers/auth_provider.dart';
import 'package:fmecg_mobile/constants/color_constant.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore_for_file: must_be_immutable
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final paddingLoginHorizontal30 = const EdgeInsets.symmetric(horizontal: 30);
  bool isSigningUp = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FocusNode focusNodeEmail = FocusNode();
  FocusNode focusNodePassword = FocusNode();
  FocusNode focusNodeConfirmPassword = FocusNode();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool loginProcess = false;

  bool _obscureText = true;
  bool _obscureConfirmText = true;

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

  bool isSamePassword(String previous, String current) {
    return previous == current;
  }

  void _signUpUser() async {
    final AuthProvider authProvider = context.read<AuthProvider>();
    try {
      if (isSigningUp) return;
      setState(() {
        isSigningUp = true;
      });
      final form = _formKey.currentState;
      form!.save();

      // if (form.validate() && Validators.isValidEmail(_emailController.text) && Validators.isValidPassword(_passwordController.text)) {
      if (form.validate()) {
        await authProvider.registerUser(_emailController.text, _passwordController.text);
      } else {
        print('show dialog or ...');
      }
      setState(() {
        isSigningUp = false;
      });
    } catch (e) {
      setState(() {
        isSigningUp = false;
      });
    }
  }

  Widget _formSignUpUser() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: ColorConstant.quinary, borderRadius: BorderRadius.circular(12)),
            child: TextFormField(
              controller: _emailController,
              focusNode: focusNodeEmail,
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
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(color: ColorConstant.quinary, borderRadius: BorderRadius.circular(12)),
            child: TextFormField(
              obscureText: _obscureConfirmText,
              controller: _confirmPasswordController,
              focusNode: focusNodeConfirmPassword,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Confirm password",
                hintStyle: TextStyle(color: ColorConstant.quaternary, fontWeight: FontWeight.bold, fontSize: 16),
                contentPadding: const EdgeInsets.only(left: 20, top: 20, bottom: 20),
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      _obscureConfirmText = !_obscureConfirmText;
                    });
                  },
                  child: Icon(_obscureConfirmText ? Icons.visibility_off : Icons.visibility, color: Colors.black),
                ),
              ),
              style: const TextStyle(color: Colors.black),
              validator: (value) {
                if (!isSamePassword(value!, _passwordController.text)) {
                  return "Confirm password must match the previous ";
                }
                if (value.isEmpty) {
                  return "Password can't left empty";
                }
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: paddingLoginHorizontal30,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // logo
                  const Image(image: AssetImage("assets/images/fm_ecg.png"), height: 100),
                  // welcome
                  Text(
                    S.current.registration,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: ColorConstant.quaternary),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Please enter your email or mobile number\nto sign up",
                    style: TextStyle(fontSize: 15, color: ColorConstant.description),
                  ),
                  // 2 input
                  const SizedBox(height: 30),
                  _formSignUpUser(),
                  const SizedBox(height: 20),

                  // button login
                  Container(
                    child:
                        loginProcess
                            ? CircularProgressIndicator(color: ColorConstant.primary)
                            : SubmitButton(onTap: _signUpUser, text: "Proceed"),
                  ),

                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?", style: TextStyle(color: Colors.black)),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "  Login",
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
      ),
    );
  }
}
