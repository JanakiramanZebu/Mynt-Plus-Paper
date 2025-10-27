// import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';

// class MyCarousel extends StatefulWidget {
//   const MyCarousel({super.key});

//   @override
//   _MyCarouselState createState() => _MyCarouselState();
// }

// class _MyCarouselState extends State<MyCarousel> {
//   int _currentIndex = 0;

//   final List<String> imgList = [
//     '1',
//     '2',
//     '3',
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         CarouselSlider.builder(
//           itemCount: imgList.length,
//           itemBuilder: (context, index, realIndex) {
//             return Container(
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(16),
//                   gradient: const LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Color(0x332E65F6), // 20% opacity
//                       Color(0x0D2E65F6), // 5% opacity
//                     ],
//                   )),
//               // height: 20,
//               width: double.infinity,
//               child: const Center(child: Text("")),
//             );
//           },
//           options: CarouselOptions(
//             autoPlay: true,
//             enlargeCenterPage: true,
//             viewportFraction: 1,
//             aspectRatio: 36 / 9,
//             onPageChanged: (index, reason) {
//               setState(() {
//                 _currentIndex = index;
//               });
//             },
//           ),
//         ),

//         // Indicator (Dots)
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: imgList.asMap().entries.map((entry) {
//             return GestureDetector(
//               onTap: () => setState(() => _currentIndex = entry.key),
//               child: Container(
//                 width: _currentIndex == entry.key ? 12.0 : 8.0,
//                 height: 8.0,
//                 margin:
//                     const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: _currentIndex == entry.key
//                       ? const Color(0xff0037B7).withOpacity(0.6)
//                       : const Color(0xffD9D9D9),
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }
// }
