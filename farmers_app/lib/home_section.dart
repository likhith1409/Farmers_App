import 'package:flutter/material.dart' as flutter;
import 'add_crop_details.dart';
import 'crop_details.dart';
import 'invoice_generator.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Represents the home section of the app where farmers can view and manage their crop details.
///
class HomeSection extends flutter.StatefulWidget {
  final int farmerId;

  /// Constructor for HomeSection.
  ///
  /// Parameters:
  /// - farmerId: The ID of the farmer whose details are being displayed.
  const HomeSection({super.key, required this.farmerId});

  @override
  flutter.State<HomeSection> createState() => _HomeSectionState();
}

class _HomeSectionState extends flutter.State<HomeSection> {
  List<Map<String, dynamic>> cropDetailsList = [];
  double totalDroneUsageAcreage = 0.0;
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    fetchCropDetails();
    fetchDroneUsage();
  }

  /// Fetches the crop details for the farmer from the server.
  Future<void> fetchCropDetails() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.4:5000/get_crops/${widget.farmerId}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        cropDetailsList = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      });
    }
  }

  /// Fetches the drone usage details for the farmer from the server.
  Future<void> fetchDroneUsage() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.4:5000/get_drone_usage/${widget.farmerId}'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        totalDroneUsageAcreage = data['total_drone_usage_acreage'];
        totalAmount = data['total_amount'];
      });
    }
  }

  /// Removes the crop details at the specified index.
  ///
  /// Parameters:
  /// - index: The index of the crop details to be removed.
  void removeCropDetails(int index) {
    setState(() {
      cropDetailsList.removeAt(index);
    });
    fetchDroneUsage();
  }

  @override
  flutter.Widget build(flutter.BuildContext context) {
    return flutter.Scaffold(
      backgroundColor: const flutter.Color(0xFFF1FEFA),
      body: flutter.Padding(
        padding: const flutter.EdgeInsets.all(16.0),
        child: flutter.Column(
          crossAxisAlignment: flutter.CrossAxisAlignment.start,
          children: [
            const flutter.SizedBox(height: 17),
            flutter.Row(
              mainAxisAlignment: flutter.MainAxisAlignment.spaceBetween,
              children: [
                flutter.Image.asset(
                  'assets/logo2.png',
                  height: 40,
                ),
                const flutter.CircleAvatar(
                  radius: 20,
                  backgroundImage: flutter.AssetImage('assets/profile_icon.png'),
                ),
              ],
            ),
            const flutter.SizedBox(height: 50),

            // Add Crop Details section
            const flutter.Text(
              'Add Crop Details:',
              style: flutter.TextStyle(
                fontSize: 18,
                fontWeight: flutter.FontWeight.bold,
              ),
            ),
            const flutter.SizedBox(height: 10),
            flutter.Container(
              height: 100,
              decoration: flutter.BoxDecoration(
                color: const flutter.Color(0xFFD9D9D9),
                borderRadius: const flutter.BorderRadius.only(
                  topLeft: flutter.Radius.circular(10),
                  bottomLeft: flutter.Radius.circular(10),
                ),
                boxShadow: [
                  flutter.BoxShadow(
                    color: flutter.Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const flutter.Offset(0, 4),
                  ),
                ],
              ),
              child: flutter.ListView.builder(
                scrollDirection: flutter.Axis.horizontal,
                itemCount: cropDetailsList.length + 1,
                itemBuilder: (context, index) {
                  if (index < cropDetailsList.length) {
                    final cropDetails = cropDetailsList[index];
                    return flutter.Padding(
                      padding: const flutter.EdgeInsets.symmetric(horizontal: 8.0),
                      child: flutter.GestureDetector(
                        onTap: () {
                          flutter.Navigator.push(
                            context,
                            flutter.MaterialPageRoute(
                              builder: (context) => CropDetails(
                                cropName: cropDetails['crop_name'],
                                imagePath: cropDetails['image_path'],
                                isEditable: true,
                                farmerId: widget.farmerId,
                                cropId: cropDetails['id'], 
                              ),
                            ),
                          ).then((value) {
                            if (value != null && value == 'remove') {
                              removeCropDetails(index);
                            }
                          });
                        },
                        child: flutter.CircleAvatar(
                          radius: 30,
                          backgroundImage: flutter.AssetImage(cropDetails['image_path']),
                        ),
                      ),
                    );
                  } else {
                    return flutter.Padding(
                      padding: const flutter.EdgeInsets.symmetric(horizontal: 8.0),
                      child: flutter.CircleAvatar(
                        radius: 30,
                        backgroundColor: flutter.Colors.grey[200],
                        child: flutter.IconButton(
                          icon: const flutter.Icon(
                            flutter.Icons.add,
                            color: flutter.Colors.green,
                          ),
                          onPressed: () async {
                            final cropDetails = await flutter.Navigator.push(
                              context,
                              flutter.MaterialPageRoute(
                                builder: (context) => AddCropDetails(farmerId: widget.farmerId),
                                settings: flutter.RouteSettings(arguments: cropDetailsList),
                              ),
                            );
                            if (cropDetails != null) {
                              fetchCropDetails();
                              fetchDroneUsage();
                            }
                          },
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            const flutter.SizedBox(height: 50),

            // Drone Usage Caliculation Section
            const flutter.Text(
              'Drone Usage:',
              style: flutter.TextStyle(
                fontSize: 18,
                fontWeight: flutter.FontWeight.bold,
              ),
            ),
            const flutter.SizedBox(height: 10),
            flutter.Center(
              child: flutter.Container(
                width: double.infinity,
                padding: const flutter.EdgeInsets.all(16.0),
                decoration: flutter.BoxDecoration(
                  color: const flutter.Color(0xFFD9D9D9),
                  borderRadius: flutter.BorderRadius.circular(10),
                  boxShadow: [
                    flutter.BoxShadow(
                      color: flutter.Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const flutter.Offset(0, 4),
                    ),
                  ],
                ),
                child: flutter.Column(
                  mainAxisAlignment: flutter.MainAxisAlignment.center,
                  children: [
                    const flutter.Text(
                      '1 Acre = ₹200', // Added Default Value for Caliculation
                      style: flutter.TextStyle(
                        fontSize: 20,
                        fontWeight: flutter.FontWeight.bold,
                        color: flutter.Colors.black,
                      ),
                      textAlign: flutter.TextAlign.center,
                    ),
                    const flutter.SizedBox(height: 10),
                    flutter.Row(
                      mainAxisAlignment: flutter.MainAxisAlignment.start,
                      children: [
                        const flutter.SizedBox(width: 10),
                        flutter.Text(
                          'Total Drone Usage: ${totalDroneUsageAcreage.toStringAsFixed(2)} Acres\nTotal Amount: ₹${totalAmount.toStringAsFixed(2)}',
                          style: const flutter.TextStyle(
                            fontSize: 20,
                            fontWeight: flutter.FontWeight.bold,
                            color: flutter.Colors.black,
                          ),
                          textAlign: flutter.TextAlign.left,
                        ),
                      ],
                    ),
                    const flutter.SizedBox(height: 20),
                    flutter.ElevatedButton(
                      onPressed: () async {
                        await generateInvoice(widget.farmerId, context);
                      },
                      style: flutter.ElevatedButton.styleFrom(
                        backgroundColor: const flutter.Color(0xFF0E8059),
                        shape: flutter.RoundedRectangleBorder(
                          borderRadius: flutter.BorderRadius.circular(20),
                        ),
                      ),
                      child: const flutter.Padding(
                        padding: flutter.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: flutter.Text(
                          'Download Invoice',
                          style: flutter.TextStyle(
                            color: flutter.Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
