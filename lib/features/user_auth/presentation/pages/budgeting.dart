import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class BudgetingPage extends StatefulWidget {
  @override
  _BudgetingPageState createState() => _BudgetingPageState();
}

class _BudgetingPageState extends State<BudgetingPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double setBudget = 0.0;
  double totalSpent = 0.0;
  double totalDebt = 0.0;

  List<Map<String, dynamic>> recentTransactions = [];
  List<Map<String, dynamic>> debtHistory = [];

  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _debtAmountController = TextEditingController();
  final TextEditingController _debtTypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchDebtData();
  }

  Future<void> _fetchData() async {
    String? userId = _auth.currentUser?.email?.split('@')[0];

    if (userId != null) {
      DocumentSnapshot budgetDoc =
      await _firestore.collection('budgets').doc(userId).get();
      setBudget = budgetDoc.exists ? budgetDoc['budget'] : 0.0;

      QuerySnapshot expenseSnapshot = await _firestore
          .collection('transactions')
          .doc(userId)
          .collection('userTransactions')
          .orderBy('date', descending: true)
          .limit(5)
          .get();

      setState(() {
        totalSpent = expenseSnapshot.docs.fold(
          0,
              (sum, doc) =>
          sum +
              (doc['amount'] is String
                  ? double.tryParse(doc['amount']) ?? 0.0
                  : (doc['amount'] as num).toDouble()),
        );

        recentTransactions = expenseSnapshot.docs.map((doc) =>
        {
          'type': doc['type'],
          'amount': doc['amount'],
          'date': (doc['date'] as Timestamp).toDate(),
        }).toList();
      });
    }
  }

  Future<void> _fetchDebtData() async {
    String? userId = _auth.currentUser?.email?.split('@')[0];

    if (userId != null) {
      QuerySnapshot debtSnapshot = await _firestore
          .collection('debt')
          .doc(userId)
          .collection('userDebts')
          .orderBy('date', descending: true)
          .get();

      setState(() {
        totalDebt = debtSnapshot.docs.fold(
          0,
              (sum, doc) =>
          sum +
              (doc['amount'] is String
                  ? double.tryParse(doc['amount']) ?? 0.0
                  : (doc['amount'] as num).toDouble()),
        );

        debtHistory = debtSnapshot.docs.map((doc) {
          return {
            'id': doc.id, // Document ID for deletion
            'type': doc['type'],
            'amount': doc['amount'],
            'date': (doc['date'] as Timestamp).toDate(),
          };
        }).toList();
      });
    }
  }

  Future<void> _deleteDebt(String debtId) async {
    String? userId = _auth.currentUser?.email?.split('@')[0];

    if (userId != null) {
      await _firestore
          .collection('debt')
          .doc(userId)
          .collection('userDebts')
          .doc(debtId)
          .delete();

      _fetchDebtData(); // Refresh debt data
    }
  }

  Future<void> _setBudget() async {
    String? userId = _auth.currentUser?.email?.split('@')[0];

    if (userId != null) {
      setBudget = double.tryParse(_budgetController.text) ?? 0.0;

      await _firestore.collection('budgets').doc(userId).set({
        'budget': setBudget,
      }, SetOptions(merge: true));

      _budgetController.clear();
      setState(() {});
    }
  }

  Future<void> _addDebt() async {
    String? userId = _auth.currentUser?.email?.split('@')[0];

    if (userId != null) {
      double debtAmount = double.tryParse(_debtAmountController.text) ?? 0.0;
      String debtType = _debtTypeController.text;

      await _firestore
          .collection('debt')
          .doc(userId)
          .collection('userDebts')
          .add({
        'amount': debtAmount,
        'type': debtType,
        'date': Timestamp.now(),
      });

      _debtAmountController.clear();
      _debtTypeController.clear();
      _fetchDebtData(); // Refresh debt data
    }
  }

  void _showAddDebtDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Debt",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _debtAmountController,
                decoration: InputDecoration(hintText: "Enter debt amount"),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: _debtTypeController,
                decoration: InputDecoration(hintText: "Enter debt type"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Add",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              onPressed: () {
                _addDebt();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Cancel",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double remainingBudget = setBudget - totalSpent;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Budgeting",
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
        child: ListView(
          children: [
            TextField(
              controller: _budgetController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter budget amount",
                fillColor: Color(0xFFF0F4C3),
                filled: true,
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _setBudget,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Color(0xFFC5E1A5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                shadowColor: Colors.greenAccent,
                elevation: 5,
              ),
              child: Text(
                "Set Budget",
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text("Budget Breakdown",
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            Card(
              elevation: 4,
              color: Color(0xFFF1F8E9),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildBudgetInfoRow("Total Spent: ", totalSpent),
                    SizedBox(height: 10),
                    _buildBudgetInfoRow("Set Budget: ", setBudget),
                    SizedBox(height: 10),
                    _buildBudgetInfoRow("Remaining Budget: ", remainingBudget),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text("Recent Expenses",
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            ...recentTransactions.map((tx) {
              return Card(
                elevation: 3,
                color: Color(0xFFE3F2FD),
                child: ListTile(
                  title: Text(
                    tx['type'],
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                      "Amount: ${tx['amount']}\nDate: ${DateFormat('yyyy-MM-dd')
                          .format(tx['date'])}"),
                ),
              );
            }).toList(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showAddDebtDialog,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.orangeAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child: Text(
                "Add Debt",
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text("Debt History",
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold)),

            SizedBox(height: 10),
            ...debtHistory.map((debt) {
              return Card(
                elevation: 3,
                color: Color(0xFFFFF9C4),
                child: ListTile(
                  title: Text(
                    debt['type'],
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                      "Amount: ${debt['amount']}\nDate: ${DateFormat(
                          'yyyy-MM-dd').format(debt['date'])}"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _deleteDebt(debt['id']);
                    },
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetInfoRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        Text(
          "${value.toStringAsFixed(2)}",
          style: GoogleFonts.poppins(),
        ),
      ],
    );
  }
}
