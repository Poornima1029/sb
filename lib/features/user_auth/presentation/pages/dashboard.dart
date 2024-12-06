import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  double totalIncome = 0;
  double totalExpense = 0;
  List<Map<String, dynamic>> recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    String? userId = _auth.currentUser?.email?.split('@')[0];

    if (userId != null) {
      QuerySnapshot incomeSnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .doc(userId)
          .collection('userTransactions')
          .where('type', isEqualTo: 'Income')
          .get();

      QuerySnapshot expenseSnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .doc(userId)
          .collection('userTransactions')
          .where('type', isEqualTo: 'Expense')
          .get();

      QuerySnapshot recentTransactionSnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .doc(userId)
          .collection('userTransactions')
          .orderBy('date', descending: true)
          .limit(5)
          .get();

      setState(() {
        totalIncome = incomeSnapshot.docs.fold(
          0,
              (sum, doc) => sum + (doc['amount'] is String
              ? double.tryParse(doc['amount']) ?? 0.0
              : (doc['amount'] as num).toDouble()),
        );

        totalExpense = expenseSnapshot.docs.fold(
          0,
              (sum, doc) => sum + (doc['amount'] is String
              ? double.tryParse(doc['amount']) ?? 0.0
              : (doc['amount'] as num).toDouble()),
        );

        recentTransactions = recentTransactionSnapshot.docs.map((doc) => {
          'type': doc['type'],
          'amount': doc['amount'],
          'date': (doc['date'] as Timestamp).toDate(),
        }).toList();
      });
    }
  }

  String formatCurrency(double amount) {
    return amount.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    double netSavings = totalIncome - totalExpense;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Dashboard",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Color(0xFFB2DFDB),
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Summary Cards Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryCard('Total Income', totalIncome, Colors.green),
                _buildSummaryCard('Total Expenses', totalExpense, Colors.red),
                _buildSummaryCard(
                    'Net Savings',
                    netSavings,
                    netSavings >= 0 ? Colors.blue : Colors.red),
              ],
            ),
            SizedBox(height: 20),

            // Bar Chart
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [
                      BarChartRodData(toY: totalIncome, color: Colors.green, width: 15),
                    ]),
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(toY: totalExpense, color: Colors.red, width: 15),
                    ]),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return Text('Income');
                            case 1:
                              return Text('Expenses');
                            default:
                              return Text('');
                          }
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  barTouchData: BarTouchData(enabled: true),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Recent Transactions with Scrollbar
            Text(
              'Recent Transactions',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Expanded(
              child: Scrollbar(  // Wrap ListView with Scrollbar
                thumbVisibility: true,
                child: ListView.builder(
                  itemCount: recentTransactions.length,
                  itemBuilder: (context, index) {
                    var transaction = recentTransactions[index];
                    return ListTile(
                      title: Text(
                        '${transaction['type']}: ${formatCurrency(transaction['amount'])}',
                        style: GoogleFonts.roboto(fontSize: 18),
                      ),
                      subtitle: Text(
                        DateFormat('yyyy-MM-dd').format(transaction['date']),
                        style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/income_expenses');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF9FA8DA),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Add Income/Expense",
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Summary Card Widget
  Widget _buildSummaryCard(String title, double value, Color color) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        width: MediaQuery.of(context).size.width * 0.28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.6), color.withOpacity(0.2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              formatCurrency(value),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
