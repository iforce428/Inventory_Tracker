import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:invent_track_mobile/backend/Item.dart';
import 'package:invent_track_mobile/backend/location.dart';

class Database {
  late final MySQLConnection _connection;

  Future<void> connect() async {
    try {
      _connection = await MySQLConnection.createConnection(
        host: "172.20.10.6",

        // Add your host IP address or server name
        port: 3306,
        // Add the port the server is running on
        userName: "remote_user",
        // Your username
        password: "pass",
        // Your password
        databaseName: "inventtrack",
        // Your DataBase name
        secure: false, // Disable SSL connection
      );

      await _connection.connect();
      print("Database connected successfully!");
    } catch (e) {
      print("Failed to connect to the database: $e");
    }
  }

  MySQLConnection get connection => _connection;

  Future<void> closeConnection() async {
    await _connection.close();
    print("Database connection closed.");
  }

  /// Function to select all items from the `Item` table
  Future<List<Item>> selectItems() async {
    List<Item> items = [];
    try {
      // Assuming `_connection` is a properly initialized database connection
      var result = await _connection.execute('SELECT * FROM item INNER JOIN location ON item.location_id=location.location_id;');

      for (var element in result.rows) {
        Map<String, dynamic> data = element.assoc();
        items.add(Item(
          itemId: int.tryParse(data['item_id']),
          itemName: data['item_name'],
          itemQuantity: int.tryParse(data['item_quantity']),
          itemMinstock: int.tryParse(data['item_minstock']),
          itemUnit: data['item_unit'],
          itemSize: data['item_size'],
          itemImage: data['item_image'],
          locationId: int.tryParse(data['location_id']),
          location_name: (data['location_name']),
          lastUpdatedBy: int.tryParse(data['last_updated_by']),
          lastUpdatedDate: data['last_updated_date'] != null
              ? DateTime.tryParse(data['last_updated_date'])
              : null,
        ));

        // Optional: Log or debug print
        print(
            'Item ID: ${data['item_id']}, Name: ${data['item_name']}, Quantity: ${data['item_quantity']}, '
                'Min Stock: ${data['item_minstock']}, Unit: ${data['item_unit']}, Size: ${data['item_size']}, '
                'Location ID: ${data['location_id']}, Location Name: ${data['location_name']},  Last Updated By: ${data['last_updated_by']}, '
                'Last Updated Date: ${data['last_updated_date']}, image_path: ${data['item_image']}');
      }
    } catch (e) {
      print("Error fetching items: $e");
    }
    return items; // Return the list of items
  }

  Future<Item?> selectItemById(int? itemId) async {
    try {
      // Assuming `_connection` is a properly initialized database connection
      var result = await _connection.execute(
        'SELECT * FROM item INNER JOIN location ON item.location_id = location.location_id WHERE item.item_id = :itemID',
        {'itemID': itemId},
      ); // Using parameterized query to prevent SQL injection

      if (result.rows.isNotEmpty) {
        Map<String, dynamic> data = result.rows.first.assoc();

        // Map the result to an Item object with defensive checks
        Item item = Item(
          itemId: int.tryParse(data['item_id'].toString()),
          itemName: data['item_name'] ?? '',
          itemQuantity: int.tryParse(data['item_quantity'].toString()),
          itemMinstock: int.tryParse(data['item_minstock'].toString()),
          itemUnit: data['item_unit'] ?? '',
          itemSize: data['item_size'] ?? '',
          itemImage: data['item_image'] ?? '',
          locationId: int.tryParse(data['location_id'].toString()),
          location_name: data['location_name'] ?? '',
          lastUpdatedBy: int.tryParse(data['last_updated_by'].toString()),
          lastUpdatedDate: data['last_updated_date'] != null
              ? DateTime.tryParse(data['last_updated_date'])
              : null,
        );
        print(
            'Item ID: ${data['item_id']}, Name: ${data['item_name']}, Quantity: ${data['item_quantity']}, '
                'Min Stock: ${data['item_minstock']}, Unit: ${data['item_unit']}, Size: ${data['item_size']}, '
                'Location ID: ${data['location_id']}, Location Name: ${data['location_name']},  Last Updated By: ${data['last_updated_by']}, '
                'Last Updated Date: ${data['last_updated_date']}, image_path: ${data['item_image']}');
        // Return the fetched item
        return item;
      } else {
        print("No item found with ID: $itemId");
        return null;
      }
    } catch (e) {
      print("Error fetching item with ID $itemId: $e");
      return null;
    }
  }



  Future<List<Item>> selectLowItems() async {
    List<Item> items = [];
    try {
      // Assuming `_connection` is a properly initialized database connection
      var result = await _connection.execute('SELECT * FROM item INNER JOIN location ON item.location_id=location.location_id WHERE item.item_quantity < item.item_minstock;');

      for (var element in result.rows) {
        Map<String, dynamic> data = element.assoc();
        items.add(Item(
          itemId: int.tryParse(data['item_id']),
          itemName: data['item_name'],
          itemQuantity: int.tryParse(data['item_quantity']),
          itemMinstock: int.tryParse(data['item_minstock']),
          itemUnit: data['item_unit'],
          itemSize: data['item_size'],
          itemImage: data['item_image'],
          locationId: int.tryParse(data['location_id']),
          location_name: (data['location_name']),
          lastUpdatedBy: int.tryParse(data['last_updated_by']),
          lastUpdatedDate: data['last_updated_date'] != null
              ? DateTime.tryParse(data['last_updated_date'])
              : null,
        ));

        // Optional: Log or debug print
        print("hello");
        print(
            'Item ID: ${data['item_id']}, Name: ${data['item_name']}, Quantity: ${data['item_quantity']}, '
                'Min Stock: ${data['item_minstock']}, Unit: ${data['item_unit']}, Size: ${data['item_size']}, '
                'Location ID: ${data['location_id']}, Location Name: ${data['location_name']},  Last Updated By: ${data['last_updated_by']}, '
                'Last Updated Date: ${data['last_updated_date']}, image_path: ${data['item_image']}');
      }
    } catch (e) {
      print("Error fetching items: $e");
    }
    return items; // Return the list of items
  }

  Future<String> authLogin(String email, String password) async {
    try {
      // Use parameterized query to prevent SQL injection
      var result = await _connection.execute(
          'SELECT staff_id FROM staff WHERE staff_email = :email AND staff_password = :password',
          {'email': email, 'password': password}
      );

      // Check if the result contains a row
      if (result.rows.isNotEmpty) {
        // Get the staff ID from the result
        Map<String, dynamic> data = result.rows.first.assoc();
        return 'Staff ID: ${data['staff_id']}'; // Return the staff ID
      } else {
        return 'Login failed: Invalid email or password'; // Invalid login credentials
      }
    } catch (e) {
      // Handle any errors that occur during the query
      return 'Error during login: $e';
    }
  }

  Future<bool> createAccount(String name, String email, String password) async {
    try {
      // Use parameterized query to prevent SQL injection
      var result = await connection.execute(
        "INSERT INTO staff (staff_name, staff_email, staff_password) VALUES (:name, :email, :password)",
        {'name': name, 'email': email, 'password': password},
      );

      // Check if the row was inserted successfully
      if (result.affectedRows > BigInt.zero) { // Use BigInt for comparison
        print('Inserted row id=${result.lastInsertID}');
        return true; // Account creation successful
      } else {
        return false; // Account creation failed
      }
    } catch (e) {
      // Handle any errors that occur during the query
      print('Error during account creation: $e');
      return false; // Indicate failure
    }
  }

  Future<int?> totalItems() async {
    try {
      var result = await connection.execute(
          'SELECT COUNT(*) as count FROM item');

      // Iterate over rows (although we expect only one row)
      for (var element in result) {
        // Extract the count from the first row (since it's a single row result)
        Map<String, dynamic> data = result.rows.first.assoc();
        int? count = int.tryParse(data['count']); // Access the 'count' field

        print('Total items: $count');
        return count;
      }

      // If no rows, return 0
      return 0;
    } catch (e) {
      print('Error fetching total items: $e');
      return 0; // Return 0 if there's an error
    }
  }

  Future<int?> lowStock() async {
    try {
      var result = await connection.execute(
          'SELECT COALESCE(COUNT(*), 0) AS low_stock_count FROM item WHERE item_quantity < item_minstock;'
      );

      // Check if rows exist
      if (result.rows.isNotEmpty) {
        // Extract the first row
        Map<String, dynamic> data = result.rows.first.assoc();

        // Access the 'low_stock_count' field
        int count = int.tryParse(data['low_stock_count']) ??
            0; // Ensure no null values

        print('Total low stock items: $count');
        return count;
      }

      // If no rows, return 0
      return 0;
    } catch (e) {
      print('Error fetching low stock items: $e');
      return 0; // Return 0 in case of an error
    }
  }


  Future<void> insertItem(Item item) async {
    try {
      // Convert item object to JSON map
      Map<String, dynamic> itemJson = item.toJson();

      var result = await connection.execute('''
    INSERT INTO Item (
      item_name, 
      item_quantity, 
      item_minstock, 
      item_unit, 
      item_size, 
      item_image, 
      location_id, 
      last_updated_by, 
      last_updated_date
    ) 
    VALUES (
      :item_name, :item_quantity, :item_minstock, :item_unit, :item_size, 
      :item_image, :location_id, :last_updated_by, :last_updated_date
    )
  ''', itemJson); // Pass itemJson directly

      // Optional: Log or debug print
      print("Item inserted successfully: ${item.itemName}");
    } catch (e) {
      print("Error inserting item: $e");
    }
  }

  Future<void> updateItem(Item item) async {
    try {
      // Convert item object to JSON map
      Map<String, dynamic> itemJson = item.toJson();

      var result = await connection.execute('''
    UPDATE Item 
    SET 
      item_name = :item_name, 
      item_quantity = :item_quantity, 
      item_minstock = :item_minstock, 
      item_unit = :item_unit, 
      item_size = :item_size, 
      item_image = :item_image, 
      location_id = :location_id, 
      last_updated_by = :last_updated_by, 
      last_updated_date = :last_updated_date
    WHERE item_id = :item_id
    ''', itemJson); // Pass itemJson directly

      // Log or debug print
      print("Item updated successfully: ${item.itemName}, Rows affected: ${result.affectedRows}");
    } catch (e) {
      print("Error updating item: $e");
    }
  }

  Future<List<Location>> selectLocations() async {
    List<Location> locations = [];
    try {
      // Assuming `_connection` is a properly initialized database connection
      var result = await _connection.execute('SELECT * FROM Location');

      for (var element in result.rows) {
        Map data = element.assoc(); // Removed type annotation for simplicity
        print('Location ID: ${data['location_id']}, Name: ${data['location_name']}');

        locations.add(Location(
          locationId: int.tryParse(data['location_id'].toString()) ?? 0, // Convert to string before parsing
          locationName: data['location_name'] ?? '', // Default to empty string if null
        ));
      }
    } catch (e) {
      print("Error fetching locations: $e");
    }
    return locations;
  }

}


