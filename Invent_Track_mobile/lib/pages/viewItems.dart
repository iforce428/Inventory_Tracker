import 'package:flutter/material.dart';
import 'package:invent_track_mobile/backend/Item.dart'; // Import your Item model
import 'package:invent_track_mobile/backend/dbconn.dart'; // Import your database connection
import 'package:invent_track_mobile/pages/updateItems.dart'; // Import the UpdateItemPage
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class ItemListPage extends StatefulWidget {
  @override
  _ItemListPageState createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  List<Item> _items = [];
  final String uri = "http://172.20.10.6/"; // Base URI for images
  String stock = "";

  @override
  void initState() {
    super.initState();
    _getStock();
    _loadItems();
  }
  Future<void> _getStock() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      stock = prefs.getString('stock') ?? "";
    });
  }

  Future<void> _loadItems() async {
    Database db = Database(); // Assuming your DB class is called Database
    await db.connect();

    try {
      List<Item> items;
      if(stock == "normal"){
        items = await db.selectItems(); // Assuming selectItems() fetches items
      }else{
        items = await db.selectLowItems();
      }
      setState(() {
        _items = items; // Update the state with the fetched items
      });
      await db.closeConnection();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading items: $e")),
      );
    }
  }

  Future<void> _saveItemId(int? itemId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('item_id', itemId!); // Store the itemId in SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: stock == "normal"
            ? const Text('Item List')
            : const Text('Low Stock List'),
      ),
      body: _items.isEmpty
          ? const Center(child: CircularProgressIndicator()) // Show a loading indicator if items are empty
          : ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return Card(
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: item.itemImage != null
                  ? CircleAvatar(
                backgroundImage: NetworkImage('$uri${item.itemImage}'),
                radius: 25, // Set a fixed radius
              )
                  : const Icon(Icons.image, size: 50), // Default icon if no image
              title: Text(item.itemName ?? "Unknown Item"),
              subtitle: Text("Quantity: ${item.itemQuantity}\nLocation: ${item.location_name}"),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () async {
                // Save itemId to SharedPreferences before navigating
                await _saveItemId(item.itemId);

                // Navigate to UpdateItemPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateItemPage(), // No need to pass itemId directly
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
