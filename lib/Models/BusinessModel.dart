class Business {
  final int id; // Unique ID
  final String name;
  final String description;
  final String category;
  final String location;
  final int totalProducts;
  final String phone;
  final String? website; // optional
  final String? image; // optional image URL or path
  final DateTime date; // date when the business was added

  Business({
    this.id = 0,
    this.name = "",
    this.description = "",
    this.category = "",
    this.location = "",
    this.totalProducts = 0,
    this.phone = "",
    this.website,
    this.image,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'location': location,
      'phone': phone,
      'website': website,
      'image': image,
      'date': date.toIso8601String(),
    };
  }

  factory Business.fromMap(Map<String, dynamic> map) {
    return Business(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      location: map['location'],
      phone: map['phone'],
      website: map['website'],
      image: map['image'],
      date: DateTime.parse(map['date']),
    );
  }

  // Convert Business object to JSON (useful for saving in DB or API)
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category,
    'location': location,
    'totalProducts': totalProducts,
    'phone': phone,
    'website': website,
    'image': image,
    'date': date.toIso8601String(),
  };

  // Create Business object from JSON
  factory Business.fromJson(Map<String, dynamic> json) => Business(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    category: json['category'],
    location: json['location'],
    totalProducts: json['totalProducts'],
    phone: json['phone'],
    website: json['website'],
    image: json['image'],
    date: DateTime.parse(json['date']),
  );
}
