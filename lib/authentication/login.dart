import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uber_seller/global/global.dart';
import 'package:uber_seller/mainScreens/home_screen.dart';
import 'package:uber_seller/widgets/custom_text_field.dart';
import 'package:uber_seller/widgets/error_dialog.dart';
import 'package:uber_seller/widgets/loading_dialog.dart';

import 'auth_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  formValidation() {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      //Login
      loginNow();
    } else {
      showDialog(
        context: context,
        builder: (c) {
          return ErrorDialog(
            message: "Please write email/password.",
          );
        },
      );
    }
  }

  loginNow() async {
    showDialog(
      context: context,
      builder: (c) {
        return LoadingDialog(
          message: "Checking Credentials.",
        );
      },
    );
    User? currentUser;
    await firebaseAuth
        .signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    )
        .then((auth) {
      currentUser = auth.user!;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (c) {
          return ErrorDialog(
            message: error.message.toString(),
          );
        },
      );
    });
    if (currentUser != null) {
      readDataAndSetDataLocally(currentUser!);
    }
  }

  Future readDataAndSetDataLocally(User currentUser) async {
    await FirebaseFirestore.instance
        .collection("sellers")
        .doc(currentUser.uid)
        .get()
        .then((snapshot) async {
      if (snapshot.exists) {
        await sharedPreferences!.setString("uid", currentUser.uid);
        await sharedPreferences!
            .setString("email", snapshot.data()!["sellerEmail"]);
        await sharedPreferences!
            .setString("name", snapshot.data()!["sellerName"]);
        await sharedPreferences!
            .setString("photoUrl", snapshot.data()!["sellerAvatarUrl"]);
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const HomeScreen()));
      } else {
        firebaseAuth.signOut();
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const AuthScreen()));

        showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: "No record found, Try Registering",
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Image.asset(
                  "images/seller.png",
                  height: 270,
                ),
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    data: Icons.email,
                    controller: emailController,
                    hintText: "Email",
                    isObscure: false,
                  ),
                  CustomTextField(
                    data: Icons.lock,
                    controller: passwordController,
                    hintText: "Password",
                    isObscure: true,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () {
                formValidation();
              },
              child: const Text(
                "Login as an Engineer",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
