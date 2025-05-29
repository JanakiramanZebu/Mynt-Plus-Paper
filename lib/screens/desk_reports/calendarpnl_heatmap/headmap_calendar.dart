// import 'package:flutter/material.dart';
// import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: HeatmapCalendarScreen(),
//     );
//   }
// }

// class HeatmapCalendarScreen extends StatefulWidget {
//   @override
//   _HeatmapCalendarScreenState createState() => _HeatmapCalendarScreenState();
// }

// class _HeatmapCalendarScreenState extends State<HeatmapCalendarScreen> {
//   DateTime selectedMonth = DateTime.now();
//   Map<DateTime, int> heatmapData = {
//     DateTime(2024, 3, 1): 1,
//     DateTime(2024, 3, 5): 2,
//     DateTime(2024, 3, 10): 3,
//     DateTime(2024, 3, 15): 4,
//     DateTime(2024, 3, 20): 5,
//     DateTime(2024, 3, 22): 2,
//     DateTime(2024, 3, 24): 3,
//     DateTime(2024, 3, 27): 6,
//   };

//   void _changeMonth(int increment) {
//     setState(() {
//       selectedMonth = DateTime(
//         selectedMonth.year,
//         selectedMonth.month + increment,
//         1,
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "${_getMonthName(selectedMonth.month)} ${selectedMonth.year}",
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0, 
//         actions: [
          
//         ],
//       ),
//       body: Column(
//         children: [
//           IconButton(
//           icon: Icon(Icons.arrow_back_ios, color: Colors.black),
//           onPressed: () => _changeMonth(-1),),
//           IconButton(
//             icon: Icon(Icons.arrow_forward_ios, color: Colors.black),
//             onPressed: () => _changeMonth(1),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: HeatMap(
//               startDate: DateTime(selectedMonth.year, selectedMonth.month, 1),
//               endDate: DateTime(selectedMonth.year, selectedMonth.month + 1, 0),
//               datasets: heatmapData,
//               colorMode: ColorMode.color,
//               showText: false,
//               scrollable: false,
//               colorsets: {
//                 1: Colors.red[100]!,
//                 2: Colors.red[200]!,
//                 3: Colors.red[300]!,
//                 4: Colors.red[400]!,
//                 5: Colors.red[500]!,
//                 6: Colors.red[600]!,
//               },
//               onClick: (date) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text("Clicked on ${date.toString().split(' ')[0]}")),
//                 );
//               },
//             ),
//           ),
          
//           _buildLegend(),
//         ],
//       ),
//     );
//   }

//   /// Generates a simple heatmap legend
//   Widget _buildLegend() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text("less", style: TextStyle(fontSize: 12, color: Colors.grey)),
//           SizedBox(width: 5),
//           for (int i = 1; i <= 6; i++)
//             Container(
//               width: 20,
//               height: 10,
//               margin: EdgeInsets.symmetric(horizontal: 2),
//               decoration: BoxDecoration(
//                 color: Colors.red[100 * i],
//                 borderRadius: BorderRadius.circular(3),
//               ),
//             ),
//           SizedBox(width: 5),
//           Text("more", style: TextStyle(fontSize: 12, color: Colors.grey)),
//         ],
//       ),
//     );
//   }

//   /// Get month name from month number
//   String _getMonthName(int month) {
//     return [
//       "January", "February", "March", "April", "May", "June",
//       "July", "August", "September", "October", "November", "December"
//     ][month - 1];
//   }
// }
 