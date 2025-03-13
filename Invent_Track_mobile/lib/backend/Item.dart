class Item {
  int? itemId;
  String? itemName;
  int? itemQuantity;
  int? itemMinstock;
  String? itemUnit;
  String? itemSize;
  String? itemImage;
  int? locationId;
  String? location_name;
  int? lastUpdatedBy;
  DateTime? lastUpdatedDate;

  Item({
    this.itemId,
    this.itemName,
    this.itemQuantity,
    this.itemMinstock,
    this.itemUnit,
    this.itemSize,
    this.itemImage,
    this.locationId,
    this.location_name,
    this.lastUpdatedBy,
    this.lastUpdatedDate,
  });

  // Factory method to create an Item object from a JSON map
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemId: json['item_id'],
      itemName: json['item_name'],
      itemQuantity: json['item_quantity'],
      itemMinstock: json['item_minstock'],
      itemUnit: json['item_unit'],
      itemSize: json['item_size'],
      itemImage: json['item_image'],
      locationId: json['location_id'],
      location_name: json['location_name'],
      lastUpdatedBy: json['last_updated_by'],
      lastUpdatedDate: json['last_updated_date'] != null
          ? DateTime.parse(json['last_updated_date'])
          : null,
    );
  }

  // Method to convert an Item object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'item_name': itemName,
      'item_quantity': itemQuantity,
      'item_minstock': itemMinstock,
      'item_unit': itemUnit,
      'item_size': itemSize,
      'item_image': itemImage,
      'location_id': locationId,
      'location_name': location_name,
      'last_updated_by': lastUpdatedBy,
      'last_updated_date': lastUpdatedDate?.toIso8601String(),
    };
  }
}
