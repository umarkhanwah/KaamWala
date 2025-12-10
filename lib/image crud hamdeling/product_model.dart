// class ProductModel {
//   final String id;
//   final String protitle;
//   final String description;
//   final String price;
//   final String category;
//   final String image;

//   ProductModel({
//     required this.id,
//     required this.protitle,
//     required this.description,
//     required this.price,
//     required this.category,
//     required this.image,
//   });

//   factory ProductModel.fromFirestore(Map<String, dynamic> data, String id) {
//     return ProductModel(
//       id: id,
//       protitle: data['protitle'] ?? '',
//       description: data['Description'] ?? '',
//       price: data['price'] ?? '',
//       category: data['Category'] ?? '',
//       image: data['Image'] ?? '',
//     );
//   }
// // }
// class ProductModel {
//   final String id;
//   final String title;
//   final String des;
//   final String price;
//   final String category;
//   final String img;

//   ProductModel({
//     required this.id,
//     required this.title,
//     required this.des,
//     required this.price,
//     required this.category,
//     required this.img,
//   });

//   factory ProductModel.fromJson(Map<String, dynamic> data) {
//     return ProductModel(
//       id: data['id'] ?? '',
//       title: data['title'] ?? '',
//       des: data['des'] ?? '',
//       price: data['price'] ?? '',
//       category: data['categoryName'] ?? '',
//       img: data['img'] ?? '',
//     );
//   }
// }
class ProductModel {
  final String title;
  final String des;
  final String categoryId;
  final String categoryName;
  final String price;
  final String img;

  ProductModel({
    required this.title,
    required this.des,
    required this.categoryId,
    required this.categoryName, required this.price, required this.img,
  });

  factory ProductModel.fromJson(Map<String, dynamic> data) {
    return ProductModel(
      title: data['title'] ?? '',
      des: data['description'] ?? '',
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? '',
       price: data['price'] ?? '',
img: data['imageBase64'] ?? '',
    );
  }
}
