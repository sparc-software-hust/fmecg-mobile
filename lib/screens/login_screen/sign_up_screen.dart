import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool isValidEmail(String emailTyped) {
    // regular expression: example@email.vn (not begin with .): test@vais.vn
    final emailRegExp =
        RegExp(r"^[a-zA-Z0-9][a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegExp.hasMatch(emailTyped);
  }

  bool isValidPhoneNumber(String phoneNumberTyped) {
    // regular expression: example@email.vn (not begin with .): test@vais.vn
    final phoneNumberRegExp = RegExp(r"[0-9]{11,13}");
    return phoneNumberRegExp.hasMatch(phoneNumberTyped);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
          leading: Container(
        margin: const EdgeInsets.only(top: 8.0, left: 15.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.0),
          color: Colors.grey.shade200,
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () {},
        ),
      )),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
              ),
              margin: EdgeInsets.only(
                  top: size.height * 0.03, left: size.width * 0.05),
              padding: const EdgeInsets.all(20.0),
              child: ClipOval(
                  child: Icon(Icons.person_pin,
                      color: Colors.pink.shade300, size: 30)),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: size.width * 0.05, top: size.height * 0.03),
              child: const Text(
                "Registration",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                textAlign: TextAlign.left,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: size.width * 0.05, top: size.height * 0.01),
              child: const Text(
                "Please enter your email and mobile number, then we will send OTP to verify",
                style: TextStyle(fontSize: 15),
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: size.height * 0.03,
                      left: size.width * 0.05,
                      right: size.width * 0.05,
                    ),
                    child: TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          label: const Text(
                            "Phone number",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (!isValidPhoneNumber(value!)) {
                            return "Enter valid phone number: 11 digits";
                          }
                          if (value.isEmpty) {
                            return "Phone number can't left empty";
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: size.height * 0.01,
                      left: size.width * 0.05,
                      right: size.width * 0.05,
                    ),
                    child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintStyle: const TextStyle(color: Colors.grey),
                          label: const Text(
                            "Email",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
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
                        autovalidateMode: AutovalidateMode.onUserInteraction),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: size.height * 0.01,
                      left: size.width * 0.05,
                      right: size.width * 0.05,
                    ),
                    child: TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintStyle: const TextStyle(color: Colors.grey),
                          label: const Text(
                            "Full name",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                        ),
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Full name can't left empty";
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction),
                  ),
                ],
              ),
            ),
            Center(
              child: Container(
                margin: EdgeInsets.only(top: size.height * 0.02),
                height: size.height * 0.08,
                child: ElevatedButton(
                  onPressed: null,
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll<Color>(Colors.blue.shade700),
                    padding: MaterialStatePropertyAll<EdgeInsetsGeometry>(
                      EdgeInsets.symmetric(
                        horizontal: size.width * 0.39,
                      ),
                    ),
                  ),
                  child: const Text(
                    "Proceed",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Already have account?",
                  style: TextStyle(color: Colors.grey),
                ),
                TextButton(
                    onPressed: () {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (BuildContext context) =>
                      //             const LoginScreen()));
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(color: Colors.blue),
                    ))
              ],
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
    );
  }
}
