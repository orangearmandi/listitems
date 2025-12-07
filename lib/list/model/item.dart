class Item {
  final String collectionId;
  final String collectionName;
  final String created;
  final String descripcion;
  final String id;
  final String imagen;
  final int precio;
  final String productName;
  final String updated;

  Item({
    required this.collectionId,
    required this.collectionName,
    required this.created,
    required this.descripcion,
    required this.id,
    required this.imagen,
    required this.precio,
    required this.productName,
    required this.updated,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      collectionId: json['collectionId'],
      collectionName: json['collectionName'],
      created: json['created'],
      descripcion: json['descripcion'],
      id: json['id'],
      imagen: json['imagen'],
      precio: json['precio'],
      productName: json['product_name'],
      updated: json['updated'],
    );
  }

  String get name => productName;
  String get description => descripcion;
  String get image => imagen;
  int get price => precio;

  DateTime get createdDate => DateTime.parse(created);
  DateTime get updatedDate => DateTime.parse(updated);
}

class ApiResponse {
  final List<Item> items;
  final int page;
  final int perPage;
  final int totalItems;
  final int totalPages;

  ApiResponse({
    required this.items,
    required this.page,
    required this.perPage,
    required this.totalItems,
    required this.totalPages,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      items: (json['items'] as List)
          .map((item) => Item.fromJson(item))
          .toList(),
      page: json['page'],
      perPage: json['perPage'],
      totalItems: json['totalItems'],
      totalPages: json['totalPages'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item).toList(),
      'page': page,
      'perPage': perPage,
      'totalItems': totalItems,
      'totalPages': totalPages,
    };
  }
}
