import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'transactionhistory.dart'; // Ensure this import is present
import 'package:google_fonts/google_fonts.dart';

class IncomeExpenseScreen extends StatefulWidget {
  @override
  _IncomeExpenseScreenState createState() => _IncomeExpenseScreenState();
}

class _IncomeExpenseScreenState extends State<IncomeExpenseScreen> {
  String _transactionType = "Income"; // Default to 'Income'
  TextEditingController _amountController = TextEditingController();
  TextEditingController _notesController = TextEditingController();
  TextEditingController _customCategoryController = TextEditingController();
  String? _selectedCategory;
  DateTime? _incomeReceivedDate;
  DateTime? _expenseDueDate;
  bool _useSmartCategorization = false; // For smart categorization

  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> _customCategories = []; // List for storing custom categories

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  Future<void> _selectIncomeDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _incomeReceivedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _incomeReceivedDate)
      setState(() {
        _incomeReceivedDate = picked;
      });
  }

  Future<void> _selectExpenseDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expenseDueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _expenseDueDate)
      setState(() {
        _expenseDueDate = picked;
      });
  }

  Future<void> _addTransaction() async {
    String username = _auth.currentUser?.email?.split('@')[0] ?? "";

    if (_amountController.text.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields!')),
      );
      return;
    }

    try {
      Map<String, dynamic> transactionData = {
        'type': _transactionType,
        'amount': double.parse(_amountController.text),
        'category': _selectedCategory!,
        'notes': _notesController.text.isEmpty ? 'No notes' : _notesController.text,
        'date': _transactionType == "Income" ? _incomeReceivedDate : _expenseDueDate,
      };

      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(username)
          .collection('userTransactions')
          .add(transactionData);

      _amountController.clear();
      _notesController.clear();
      _selectedCategory = null;
      _incomeReceivedDate = null;
      _expenseDueDate = null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaction added successfully')),
      );
    } catch (e) {
      print("Error adding transaction: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add transaction')),
      );
    }
  }

  void _viewTransactionHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionHistoryScreen(),
      ),
    );
  }

  void _addCustomCategory() {
    if (_customCategoryController.text.isNotEmpty) {
      setState(() {
        _customCategories.add(_customCategoryController.text);
        _customCategoryController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Income & Expenses",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Color(0xFFB2DFDB),
        elevation: 4,
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Add Income & Expenses",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF80CBC4),
                    fontFamily: 'Roboto',
                  ),
                ),
                SizedBox(height: 20),

                // Smart Categorization Switch

                SizedBox(height: 15),

                // Transaction Type Dropdown
                DropdownButtonFormField<String>(
                  value: _transactionType,
                  decoration: InputDecoration(
                    labelText: "Transaction Type",
                    labelStyle: TextStyle(
                      color: Color(0xFF80CBC4),
                      fontSize: 18,
                      fontFamily: 'Roboto',
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: [
                    DropdownMenuItem(value: "Income", child: Text("Income")),
                    DropdownMenuItem(value: "Expense", child: Text("Expense")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _transactionType = value ?? "Income";
                      _selectedCategory = null;
                    });
                  },
                ),
                SizedBox(height: 15),

                // Amount Text Field
                TextField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: "Amount",
                    hintText: "Enter amount",
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Roboto',
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 18, fontFamily: 'Roboto'),
                ),
                SizedBox(height: 15),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: "Category",
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Roboto',
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: (_transactionType == "Income"
                      ? ["Salary", "Business", "Other"]
                      : ["Food", "Transport", "Utilities"] + _customCategories)
                      .map((category) {
                    return DropdownMenuItem(value: category, child: Text(category));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                SizedBox(height: 15),

                // Notes Text Field
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: "Notes",
                    hintText: "Optional notes",
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Roboto',
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: TextStyle(fontSize: 18, fontFamily: 'Roboto'),
                ),
                SizedBox(height: 15),

                // Custom Category Field
                if (_transactionType == "Expense")
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _customCategoryController,
                        decoration: InputDecoration(
                          labelText: "Add Custom Category",
                          hintText: "Enter custom category",
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontFamily: 'Roboto',
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: TextStyle(fontSize: 18, fontFamily: 'Roboto'),
                      ),
                      ElevatedButton(
                        onPressed: _addCustomCategory,
                        child: Text("Add Category"),
                      ),
                    ],
                  ),
                SizedBox(height: 15),

                // Income/Expense Date Selection
                if (_transactionType == "Income")
                  ListTile(
                    title: Text(_incomeReceivedDate == null
                        ? 'Select income received date'
                        : 'Income received on: ${_incomeReceivedDate!.toLocal()}'.split(' ')[0]),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () => _selectIncomeDate(context),
                  ),
                if (_transactionType == "Expense")
                  ListTile(
                    title: Text(_expenseDueDate == null
                        ? 'Select expense due date'
                        : 'Expense due on: ${_expenseDueDate!.toLocal()}'.split(' ')[0]),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () => _selectExpenseDueDate(context),
                  ),

                // Add Transaction Button
                Center(
                  child: ElevatedButton(
                    onPressed: _addTransaction,
                    child: Text("Add Transaction"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _viewTransactionHistory,
        child: Icon(Icons.history),
        backgroundColor: Color(0xFFB2DFDB),
      ),
    );
  }
}
