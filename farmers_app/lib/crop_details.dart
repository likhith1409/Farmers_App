import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

/// Represents the screen where farmers can view and edit crop details.
///
/// This widget allows farmers to input or update details such as total acreage,
/// drone usage acreage, products used, and quantity used for a specific crop.
/// It also provides an option to remove the crop if it is editable.

class CropDetails extends StatefulWidget {
  final String cropName;
  final String imagePath;
  final bool isEditable;
  final int farmerId;
  final int? cropId; 

  /// Constructor for CropDetails.
  ///
  /// Parameters:
  /// - cropName: The name of the crop.
  /// - imagePath: The path to the image asset for the crop.
  /// - isEditable: Whether the crop details can be edited.
  /// - farmerId: The ID of the farmer.
  /// - cropId: The ID of the crop, if it already exists.
  const CropDetails({
    super.key,
    required this.cropName,
    required this.imagePath,
    this.isEditable = false,
    required this.farmerId,
    this.cropId,
  });

  @override
  State<CropDetails> createState() => _CropDetailsState();
}

class _CropDetailsState extends State<CropDetails> {
  List<String> _selectedProducts = [];
  final TextEditingController _totalAcreageController = TextEditingController();
  final TextEditingController _droneUsageAcreageController = TextEditingController();
  final TextEditingController _quantityUsedController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.cropId != null) {
      fetchCropDetails();
    }
  }

  Future<void> fetchCropDetails() async {
    final response = await http.get(
      // Fetch crop details from the server
      Uri.parse('http://192.168.1.4:5000/get_crop/${widget.cropId}'),
    );

    if (response.statusCode == 200) {
      final cropDetails = jsonDecode(response.body);
      setState(() {
        _totalAcreageController.text = cropDetails['total_acreage'].toString();
        _droneUsageAcreageController.text = cropDetails['drone_usage_acreage'].toString();
        _quantityUsedController.text = cropDetails['quantity_used'].toString();
        _selectedProducts = List<String>.from(cropDetails['products_used'].split(', '));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: rootBundle.loadString('assets/crop_products.json'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            final Map<String, dynamic> cropProducts = json.decode(snapshot.data!);
            final List<String> products = List<String>.from(cropProducts[widget.cropName] ?? []);

            return Scaffold(
              appBar: AppBar(
                title: const Text('Crop Details'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'Crop Details:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Image.asset(
                        widget.imagePath,
                        height: 150,
                        width: 150,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Crop Name: ${widget.cropName}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildInputField(
                        label: 'Total Acreage',
                        hintText: 'Enter in acres',
                        keyboardType: TextInputType.number,
                        controller: _totalAcreageController,
                      ),
                      const SizedBox(height: 10),
                      _buildInputField(
                        label: 'Drone Usage Acreage',
                        hintText: 'Enter in acres',
                        keyboardType: TextInputType.number,
                        controller: _droneUsageAcreageController,
                      ),
                      const SizedBox(height: 10),
                      _buildCheckboxField(
                        label: 'Products Used',
                        items: products,
                      ),
                      const SizedBox(height: 10),
                      _buildInputField(
                        label: 'Quantity Used',
                        hintText: 'Enter in liters',
                        keyboardType: TextInputType.number,
                        controller: _quantityUsedController,
                      ),
                      const SizedBox(height: 20),
                      if (widget.isEditable)
                        ElevatedButton(
                          onPressed: () async {
                            // remove crop from the server
                            final response = await http.delete(
                              Uri.parse('http://192.168.1.4:5000/remove_crop/${widget.cropId}'),
                            );

                            if (response.statusCode == 200) {
                              if (context.mounted) {

                                Navigator.pop(context, 'remove');
                              }

                            } else {
                              if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Failed to remove crop')),
                                );
                              }
                    
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Text(
                              'Remove',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      else
                        ElevatedButton(
                          onPressed: () async {
                            // Added crop to the server
                            final response = await http.post(
                              Uri.parse('http://192.168.1.4:5000/add_crop'),
                              headers: <String, String>{
                                'Content-Type': 'application/json; charset=UTF-8',
                              },
                              body: jsonEncode(<String, dynamic>{
                                'farmer_id': widget.farmerId,
                                'crop_name': widget.cropName,
                                'image_path': widget.imagePath,
                                'total_acreage': double.parse(_totalAcreageController.text),
                                'drone_usage_acreage': double.parse(_droneUsageAcreageController.text),
                                'products_used': _selectedProducts.join(', '),
                                'quantity_used': double.parse(_quantityUsedController.text),
                              }),
                            );

                            if (response.statusCode == 201) {
                              if (context.mounted) {
                                  Navigator.pop(context, widget.imagePath);
                              }
                              
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Failed to add crop')),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Text(
                              'Add',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const Center(child: Text('Error loading data'));
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  /// Builds an input field with a label and hint text.
  ///
  /// Parameters:
  /// - label: The label text for the input field.
  /// - hintText: The hint text for the input field.
  /// - keyboardType: The type of keyboard to display.
  /// - controller: The TextEditingController for the input field.
  Widget _buildInputField({
    required String label,
    required String hintText,
    required TextInputType keyboardType,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  /// Builds a checkbox field with a label and a list of items.
  ///
  /// Parameters:
  /// - label: The label text for the checkbox field.
  /// - items: The list of items to display as checkboxes.
  Widget _buildCheckboxField({
    required String label,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        ExpansionTile(
          title: const Text('Select Products'),
          children: items.map((product) {
            return CheckboxListTile(
              title: Text(product),
              value: _selectedProducts.contains(product),
              onChanged: (value) {
                setState(() {
                  if (value != null && value) {
                    _selectedProducts.add(product);
                  } else {
                    _selectedProducts.remove(product);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
