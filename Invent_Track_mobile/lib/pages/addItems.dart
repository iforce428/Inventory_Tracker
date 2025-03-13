import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:invent_track_mobile/backend/Item.dart';
import 'package:invent_track_mobile/backend/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../backend/dbconn.dart';

class AddItemPage extends StatefulWidget {
  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _itemQuantityController = TextEditingController();
  final _itemMinStockController = TextEditingController();
  final _itemUnitController = TextEditingController();
  final _itemSizeController = TextEditingController();
  SharedPreferences? user;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  List<Location> _locations = []; // List of locations
  Location? _selectedLocation; // Selected location

  @override
  void initState() {
    super.initState();
    _fetchLocations(); // Fetch locations from the database
    _checkLoginStatus();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _fetchLocations() async {
    Database db = Database();
    await db.connect();

    try {
      List<Location> locations = await db.selectLocations();
      setState(() {
        _locations = locations;
      });
      await db.closeConnection();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching locations: $e")),
      );
    }
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user = prefs;
    });
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image first.")),
      );
      return null;
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://172.20.10.6/upload/upload.php'), // Replace with your backend URL
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        _selectedImage!.path,
      ),
    );

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await http.Response.fromStream(response);
        final responseJson = responseData.body;
        final Map<String, dynamic> jsonResponse = jsonDecode(responseJson);

        if (jsonResponse['status'] == 'success') {
          return jsonResponse['filename'];
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed with status: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
    return null;
  }

  Future<void> _submitForm() async {
    Database db = Database();
    db.connect();

    if (_formKey.currentState!.validate()) {
      String? filename = await _uploadImage();

      if (filename != null && _selectedLocation != null) {
        final item = Item(
          itemName: _itemNameController.text,
          itemQuantity: int.tryParse(_itemQuantityController.text),
          itemMinstock: int.tryParse(_itemMinStockController.text),
          itemUnit: _itemUnitController.text,
          itemSize: _itemSizeController.text,
          itemImage: '/upload/img/$filename',
          locationId: _selectedLocation!.locationId,
          lastUpdatedBy: user?.getInt('staff_id'),
          lastUpdatedDate: DateTime.now(),
        );

        try {
          await db.insertItem(item);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Item added successfully!")),
          );
          Navigator.pop(context);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error adding item: $e")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Item"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _itemNameController,
                        decoration: const InputDecoration(
                          labelText: "Item Name",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                        value == null || value.isEmpty ? "Enter item name" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _itemQuantityController,
                        decoration: const InputDecoration(
                          labelText: "Item Quantity",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                        value == null || value.isEmpty ? "Enter quantity" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _itemMinStockController,
                        decoration: const InputDecoration(
                          labelText: "Min Stock",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _itemUnitController,
                        decoration: const InputDecoration(
                          labelText: "Item Unit",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _itemSizeController,
                        decoration: const InputDecoration(
                          labelText: "Item Size",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<Location>(
                        value: _selectedLocation,
                        decoration: const InputDecoration(
                          labelText: "Location",
                          border: OutlineInputBorder(),
                        ),
                        items: _locations.map((location) {
                          return DropdownMenuItem<Location>(
                            value: location,
                            child: Text(location.locationName),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedLocation = newValue;
                          });
                        },
                        validator: (value) =>
                        value == null ? "Please select a location" : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _selectedImage != null
                  ? Image.file(
                _selectedImage!,
                height: 150,
                fit: BoxFit.cover,
              )
                  : const Text("No image selected."),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image, color: Colors.purple),
                label: const Text("Pick Image", style: TextStyle(color: Colors.purple)),
                style: TextButton.styleFrom(
                  side: BorderSide(color: Colors.purple),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("Submit", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
