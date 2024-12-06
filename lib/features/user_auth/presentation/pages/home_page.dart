import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index; // Update the state with the selected index
    });

    // Navigate to different screens based on the selected index
    switch (index) {
      case 0:
      // Handle the Home screen - if you're already on Home, you might not need to navigate again
        Navigator.pushReplacementNamed(context, '/home'); // Navigating to Home if necessary
        break;
      case 1:
      // Navigate to the Profile page when the profile icon is tapped
        Navigator.pushNamed(context, '/profile'); // Redirect to Profile page
        break;
    // You can add more cases for additional navigation options here (e.g., Income, Dashboard)
      default:
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "SMARTbUDGET",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        automaticallyImplyLeading: false,  // Add this line to remove the back arrow
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            icon: const Icon(Icons.logout),
            color: Colors.white,
          ),
        ],
        backgroundColor: Color(0xFFB2DFDB), // Soft pale teal for the AppBar
        elevation: 4, // Shadow effect
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Center the text
          children: [
            SizedBox(height: 50),
            Text(
              "Welcome to SMARTbUDGET",
              textAlign: TextAlign.center,  // Center the welcome text
              style: GoogleFonts.lora(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF81C8B8), // Soft pastel teal for header
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Manage Your Money",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 30),
            Text(
              "Get Started",
              textAlign: TextAlign.center,
              style: GoogleFonts.lora(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Black color for "Get Started"
              ),
            ),
            SizedBox(height: 20),
            // Content Area
            Expanded(
              child: Column(
                children: [
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/income_expenses');
                        },
                        child: Text(
                          "Income & Expenses",
                          style: GoogleFonts.poppins(
                            fontSize: 20, // Increased size for button text
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          backgroundColor: Color(0xFFC8E6C9), // Very light pastel green
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          shadowColor: Colors.greenAccent,
                          elevation: 5,
                        ),
                      ),
                      SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/budgeting');
                        },
                        child: Text(
                          "Budgeting",
                          style: GoogleFonts.poppins(
                            fontSize: 20, // Increased size for button text
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          backgroundColor: Color(0xFFD8F5D8), // Soft pastel green
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          shadowColor: Colors.greenAccent,
                          elevation: 5,
                        ),
                      ),
                      SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/report_analysis');
                        },
                        child: Text(
                          "Report & Analysis",
                          style: GoogleFonts.poppins(
                            fontSize: 20, // Increased size for button text
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          backgroundColor: Color(0xFFD4F1D4), // Pale pastel green for Reports
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          shadowColor: Colors.greenAccent,
                          elevation: 5,
                        ),
                      ),
                      SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/dashboard');
                        },
                        child: Text(
                          "Dashboard",
                          style: GoogleFonts.poppins(
                            fontSize: 20, // Increased size for button text
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          backgroundColor: Color(0xFFB2DFDB), // Soft pale teal for Dashboard
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          shadowColor: Colors.greenAccent,
                          elevation: 5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.grey),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: Colors.grey),
            label: "Settings",
          ),
        ],
        backgroundColor: Color(0xFFE0F2F1), // Very light teal background for bottom bar
        selectedItemColor: Color(0xFF80CBC4), // Soft teal for selected item
        unselectedItemColor: Colors.grey, // Grey for unselected items
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}


