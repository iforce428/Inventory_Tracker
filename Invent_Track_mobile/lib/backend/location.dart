class Location {
  final int locationId; // Primary key
  final String locationName; // Name of the location

  Location({
    required this.locationId,
    required this.locationName,
  });

  // Factory method to create a Location instance from a JSON object
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      locationId: json['location_id'],
      locationName: json['location_name'],
    );
  }

  // Convert a Location instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'location_id': locationId,
      'location_name': locationName,
    };
  }

  @override
  String toString() {
    return 'Location(locationId: $locationId, locationName: $locationName)';
  }
}
