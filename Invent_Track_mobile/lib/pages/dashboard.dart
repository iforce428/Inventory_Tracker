import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:invent_track_mobile/backend/dbconn.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int? lowStockCount = 2; // Default to 0 for low stock
  int? totalItem = 0; // Default to 1 for total items
  SharedPreferences? user;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Call reloadPage whenever the widget rebuilds (e.g., user navigates back)
    reloadPage();
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _getLowStockCount();
    _getTotalItems();
  }

  Future<void> reloadPage() async {
    await _getLowStockCount();
    await _getTotalItems();
  }

  // Method to fetch low stock count
  Future<void> _getLowStockCount() async {
    Database db = Database();
    await db.connect();
    int? count = await db.lowStock(); // Assuming this method fetches the count
    setState(() {
      lowStockCount = count; // Update the state with the fetched count
    });
    await db.closeConnection();
  }

  // Method to fetch total items count
  Future<void> _getTotalItems() async {
    Database db = Database();
    await db.connect();
    int? count = await db.totalItems(); // Assuming this method fetches the count
    setState(() {
      totalItem = count; // Update the state with the fetched count
    });
    await db.closeConnection();
  }

  // Function to check if the user is logged in
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? staffId = prefs.getInt('staff_id');
    setState(() {
      user = prefs;
    });

    if (staffId == null) {
      // If no Staff ID is found, redirect to login page
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  // Common button style
  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: 16),
      backgroundColor: Colors.purple,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  // Function to set low stock shared preference and navigate
  Future<void> _setLowStockAndNavigate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('stock', 'low');
    Navigator.pushNamed(context, '/view');
  }

  Future<void> setNormalAndNavigate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('stock', 'normal');
    Navigator.pushNamed(context, '/view');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        backgroundColor: Colors.white,
        title: Text(
          'InventTrack',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 30.0,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: reloadPage, // Swipe down to call the reloadPage function
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Inventory Summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Items',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '$totalItem',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _setLowStockAndNavigate,
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Low Stock Alerts',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                '$lowStockCount',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              // Navigation Options
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: setNormalAndNavigate,
                    icon: Icon(Icons.view_list, size: 24, color: Colors.white),
                    label: Text(
                      'View Inventory Items',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: _buttonStyle(),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/add');
                    },
                    icon: Icon(Icons.add_circle_outline, size: 24, color: Colors.white),
                    label: Text(
                      'Add Inventory',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: _buttonStyle(),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    icon: Icon(Icons.logout, size: 24, color: Colors.white),
                    label: Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: _buttonStyle(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
