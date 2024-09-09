// import 'dart:convert';

// class BasketModel {
//   String basketname;
//   String createdDate;
//   String max;
//   String curLength;

//   BasketModel(
//       {required this.basketname,
//       required this.createdDate,
//       required this.max,
//       required this.curLength});

//   // Convert the object to a Map
//   Map<String, dynamic> toMap() {
//     return {
//       'basketname': basketname,
//       'createdDate': createdDate,
//       'max': max,
//       'curLength': curLength
//     };
//   }

//   // Create an object from a Map
//   factory BasketModel.fromMap(Map<String, dynamic> map) {
//     return BasketModel(
//         basketname: map['basketname'],
//         createdDate: map['createdDate'],
//         max: map['max'],
//         curLength: map['curLength']);
//   }

//   // Convert the object to a JSON string
//   String toJson() => json.encode(toMap());

//   // Create an object from a JSON string
//   factory BasketModel.fromJson(String source) =>
//       BasketModel.fromMap(json.decode(source));
// }
