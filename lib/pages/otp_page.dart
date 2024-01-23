import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import '../home_page.dart';

class OtpPage extends StatefulWidget {
  String verificationId;
  String phoneNumber;
  OtpPage({super.key, required this.phoneNumber, required this.verificationId});
  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  bool isLoading = false;
  String OtpInput = '';
  final FirebaseAuth auth = FirebaseAuth.instance;
  int remainingTime = 60;
  late Timer resendTimer;
  var code = "";

  @override
  void initState() {
    super.initState();
    // Initialize any variables or states that you need.
    print(widget.verificationId);
    remainingTime = 30;
    resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      print("Timer callback - remainingTime: $remainingTime");
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          resendTimer.cancel();
        }
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: const LinearProgressIndicator())
          : Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: SingleChildScrollView(
                child: Column(
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
                    const SizedBox(height: 20.0),
                    Text(
                      "Verification Code",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10.0),
                    const Text("please enter the code",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 20.0),
                    OtpTextField(
                      mainAxisAlignment: MainAxisAlignment.center,
                      numberOfFields: 6,
                      fillColor: Colors.black.withOpacity(0.2),
                      filled: true,
                      onCodeChanged: (value) {
                        if (value.length == 1) {
                          setState(() {
                            OtpInput += value;
                          });
                        } else if (value.isEmpty) {
                          // Handle backspace if needed
                          setState(() {
                            OtpInput =
                                OtpInput.substring(0, OtpInput.length - 1);
                          });
                        }
                        // Additional handling if needed
                      },
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    SizedBox(
                      height: 60,
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF7C50FD)),
                        onPressed: () {
                          verifyOtp();
                        },
                        child: Text(
                          "Confirm",
                          style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF7C50FD),
                      ),
                      onPressed:
                          (remainingTime == 0) ? () => resendOTP() : null,
                      child: Text(
                        "Resend OTP",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    Text(
                      "Resend OTP in $remainingTime seconds",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> verifyOtp() async {
    setState(() {
      isLoading = true;
    });
    print(OtpInput);
    try {
      if (OtpInput.length < 6) {
        // Show alert for OTP less than 6 digits
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("Please enter a 6-digit OTP."),
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
        return;
      }
      print("rrrrrrrrrrrrrrrrrrrr");
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: OtpInput,
      );
      final authResult = await auth.signInWithCredential(credential);
      if (authResult.user != null) {
        // OTP verification was successful
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomePage()),
          (route) => false,
        );
      } else {
        print("User is not signed in");
      }
    } catch (e) {
      print("Failed to verify OTP: $e");
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Failed to verify OTP. Please try again."),
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
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

////////////////////resend otp function///////////////
  bool verificationSuccessful = false;
  String receivedID = '';
  int? resendToken;
  void resendOTP() {
    print("Resend OTP button pressed");
    final enteredPhoneNumber =
        widget.phoneNumber; // Get the phone number from the widget
    setState(() {
      remainingTime = 30;
      OtpInput = '';
    });
    // Start the timer
    resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      print("Timer callback - remainingTime: $remainingTime");
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          resendTimer.cancel();
        }
      });
    });

    auth.verifyPhoneNumber(
      phoneNumber: "+91 $enteredPhoneNumber",
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential).then(
              (value) => print('Logged In Successfully'),
            );
      },
      verificationFailed: (FirebaseAuthException e) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("Failed to resend OTP. Please try again."),
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
        print(e.message);
      },
      codeSent: (String verificationId, int? newResendToken) {
        // Handle the new verification ID and resend token as needed
        receivedID = verificationId;
        resendToken = newResendToken;
      },
      timeout: const Duration(seconds: 25),
      forceResendingToken: resendToken,
      codeAutoRetrievalTimeout: (String verificationId) {
        print('TimeOut....');
      },
    );
  }
}

// verifyOtp() async {
//   try {
//     print("rrrrrrrrrrrrrrrrrrrr");
//     print("Verification ID: ${widget.verificationId}");
//     print("Entered OTP: $code");
//     PhoneAuthCredential credential = PhoneAuthProvider.credential(
//         verificationId: widget.verificationId, smsCode: code.trim());
//     print("iiiiiiiiiiiiii");
//     await auth.signInWithCredential(credential).then((value) {
//       Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(
//             builder: (context) => HomePage(),
//           ),
//               (route) => false);
//     });
//     print("succeccc.........................");
//   } catch (e) {
//     print("wrong OTP");
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Error"),
//           content: Text("Wrong OTP entered. Please try again."),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 setState(() {
//                   isLoading = false;
//                 });
//               },
//               child: Text("OK"),
//             ),
//           ],
//         );
//       },
//     );
//     print(e);
//   }
// }

//otpfield
// OtpTextField(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       numberOfFields: 6,
//                       fillColor: Colors.black.withOpacity(0.2),
//                       filled: true,
//                       onCodeChanged: (value) {
//                         code = value;
//                         setState(() {
//                           OtpInput = OtpInput + value;
//                           print("55555555555");
//                           print(OtpInput);
//                         });
//                       },
//                     ),
