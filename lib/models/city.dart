class City {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;

  City({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
  });

  // Konversi dari JSON ke objek City
  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
    );
  }

  // Konversi dari objek City ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}
