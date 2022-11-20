import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:yandex_cup_reaction/chats/main_chats_page.dart';
import 'package:yandex_cup_reaction/widgets/toast_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<UserCredential?> createAccountWithEmail(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ToastWidget.showToast('The password provided is too weak.');
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
       return signInWithEmail(email, password);
        // print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final credential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ToastWidget.showToast('No user found for that email.');
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        ToastWidget.showToast('Wrong password provided for that user.');
        print('Wrong password provided for that user.');
      }
    }
    return null;
  }

  Future<void> addUserToCollection() async {
    FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).set({
      'id': FirebaseAuth.instance.currentUser?.uid,
      'name': FirebaseAuth.instance.currentUser?.displayName,
      'email': FirebaseAuth.instance.currentUser?.email,
      'photoUrl': FirebaseAuth.instance.currentUser?.photoURL,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Text(
              'Google signing',
              style: Theme.of(context).textTheme.headline5,
            ),
            Text(
              '(not for Huawei devices without GMS)',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            ElevatedButton(
              onPressed: () async {
                await signInWithGoogle();
                await addUserToCollection();
                if (mounted) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MainChatsPage()),
                  );
                }
              },
              child: const Text('Sign Google'),
            ),
            SizedBox(
              height: 48,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Email signing',
                  style: Theme.of(context).textTheme.headline5,
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(hintText: 'email'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(hintText: 'password'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final credentials =
                        await createAccountWithEmail(emailController.text, passwordController.text);
                    if (credentials != null) {
                      await addUserToCollection();
                      emailController.clear();
                      passwordController.clear();
                      if (mounted) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MainChatsPage()),
                        );
                      }
                    }
                  },
                  child: const Text('Sign with email'),
                ),
              ],
            ),
          ],
        ),
      ),
    )));
  }
}
