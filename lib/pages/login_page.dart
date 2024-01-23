import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:newsapi/home_page.dart';
import 'package:newsapi/pages/otp_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}
FirebaseAuth auth = FirebaseAuth.instance;

class _LoginPageState extends State<LoginPage> {
  TextEditingController phoneNumberController = TextEditingController();
 bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 80),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                          'https://w7.pngwing.com/pngs/308/489/png-transparent-united-states-flight-world-air-travel-travel-globe-earth-world-map.png',
                        ),
                        radius: 120,
                      ),
                    ),
                    Text(
                      "Welcome! to",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      "NEWSY",
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: Colors.deepPurple),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        controller: phoneNumberController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: Colors.black, fontSize: 16),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xFF6F7F9),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 2, color: Color(0xFF5E29F5)),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 2, color: Color(0xFF5E29F5)),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          hintText: "Enter Your Number",
                          hintStyle: TextStyle(
                            color: Color(0xFF5E29F5),
                            fontSize: 18,
                          ),
                          prefixIcon:
                              Icon(Icons.phone, color: Color(0xFF5E29F5)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                        height: 60,
                        width: MediaQuery.of(context).size.width / 1.5,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF7C50FD)),
                          onPressed: () {
                            // setState(() {
                            //   loading = true;
                            // });
                            sendOTP();
                          },
                          child: Text(
                            "Submit",
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () {
                          signInWithGoogle(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/google_logo.png',
                              height: 30,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Sign in with Google",
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF7C50FD),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),


// ... (continue with the rest of your build method)

                  ],
                ),
              ),
            ),
    );
  }

  String receivedID = '';
  int? resendToken;
  void sendOTP() {
    print("starting verify....");
    final enteredPhoneNumber = phoneNumberController.text;
    if (enteredPhoneNumber.length == 10 &&
        int.tryParse(enteredPhoneNumber) != null) {
      setState(() {
        loading = true;
      });
      auth.verifyPhoneNumber(
        phoneNumber: "+91 $enteredPhoneNumber",
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential).then(
                (value) => print('Logged In Successfully'),
              );
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e.message);
        },
        codeSent: (String verificationId, int? resendToken) async {
          receivedID = verificationId;
          resendToken = resendToken;
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpPage(
                  phoneNumber: phoneNumberController.text,
                  verificationId: verificationId),
            ),
          );
          phoneNumberController.clear();
        },
        timeout: const Duration(seconds: 25),
        forceResendingToken: resendToken,
        codeAutoRetrievalTimeout: (String verificationId) {
          print('TimeOut....');
        },
      );
    } else {
      print(
          "Entered wrong mobile number. Please enter a valid 10-digit number.");
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Invalid Mobile Number",
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text("Please enter a valid 10-digit mobile number.",
                style: TextStyle(color: Colors.red)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      setState(() {
        loading = true; // Set loading to true when the process starts
      });
      final GoogleSignInAccount? googleSignInAccount = await GoogleSignIn().signIn();
      print("Google Sign-In Account: $googleSignInAccount");
      if (googleSignInAccount == null) {
        print("User canceled Google Sign-In");
        return;
      }
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      // After successful sign-in, navigate to the home page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePage(), // Replace YourHomePage with your actual home page widget
        ),
      );
      print('Google Sign-In successful');
    } catch (error) {
      print('Google Sign-In failed: $error');
    } finally {
      setState(() {
        loading = false; // Reset loading when the process is complete
      });
    }
  }
}


//old method otp
//sendOTP() async {
//     await FirebaseAuth.instance.verifyPhoneNumber(
//       phoneNumber: "+91 ${phoneNumberController.text}",
//       verificationCompleted: (PhoneAuthCredential credential) {},
//       verificationFailed: (FirebaseAuthException e) {},
//       codeSent: (String verificationId, resend) async {
//         print('111111111111');
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => OtpPage(verificationId: verificationId),
//             ));
//       },
//       codeAutoRetrievalTimeout: (String verificationId) {
//         print('*******');
//         print(verificationId);
//         print('verificationId');
//         print('*******');
//       },
//     );
//   }
