import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  final Widget? child;
  const SplashScreen({Key? key, this.child}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  void _navigateToLogin() {
    if (widget.child != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => widget.child!),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F8E9), // Pale light background color
      body: GestureDetector(
        onTap: _navigateToLogin,  // Navigate when tapped
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Inspirational message with a good looking font at the top
            Container(
              padding: EdgeInsets.only(top: 50), // Add top padding for clarity
              child: Text(
                "Begin Your Journey with SmartBudget",
                style: GoogleFonts.pacifico(
                  fontSize: 30, // Larger size for impact
                  fontWeight: FontWeight.normal,
                  color: Colors.black, // Green color for positivity
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Centered Image below the text
            Expanded(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: 300, // Minimum width
                    minHeight: 300, // Minimum height
                  ),
                  child: Image.asset(
                    'assets/logo.png', // Ensure this path is correct
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
