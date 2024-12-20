import 'package:flutter/material.dart';
import 'crop_details.dart';

/// Represents the screen where farmers can add crop details.
///
/// This widget allows farmers to select a crop from a list of available crops.
/// If the crop is already added, it is marked as 'Added' and cannot be selected again.
/// Upon selecting a crop, the user is navigated to the CropDetails screen to input
/// additional details for the selected crop.
///
class AddCropDetails extends StatelessWidget {
  final int farmerId;

  /// Constructor for AddCropDetails.
  ///
  /// Parameters:
  /// - farmerId: The ID of the farmer adding the crop details.
  const AddCropDetails({super.key, required this.farmerId});

  @override
  Widget build(BuildContext context) {
    final cropDetailsList = ModalRoute.of(context)!.settings.arguments as List<Map<String, dynamic>>? ?? [];

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Select Crop:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              children: [
                _buildCropItem(context, 'Rice (Paddy)', 'assets/rice_paddy_image.png', cropDetailsList),
                _buildCropItem(context, 'Cotton', 'assets/cotten_image.png', cropDetailsList),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a crop item widget with an image and name.
  ///
  /// Parameters:
  /// - context: The BuildContext of the current widget tree.
  /// - cropName: The name of the crop.
  /// - imagePath: The path to the image asset for the crop.
  /// - cropDetailsList: The list of crop details that have already been added.
  Widget _buildCropItem(BuildContext context, String cropName, String imagePath, List<Map<String, dynamic>> cropDetailsList) {
    final isAdded = cropDetailsList.any((crop) => crop['crop_name'] == cropName);

    return GestureDetector(
      onTap: isAdded
          ? null
          : () async {
              final selectedImagePath = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CropDetails(cropName: cropName, imagePath: imagePath, farmerId: farmerId),
                ),
              );
              if (selectedImagePath != null) {
                if (context.mounted) {
                  Navigator.pop(context, {
                  'crop_name': cropName,
                  'image_path': imagePath,
                });
                }
              }
            },
      child: Card(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    imagePath,
                    height: 100,
                    width: 100,
                  ),
                  const SizedBox(height: 10),
                  Text(cropName),
                ],
              ),
            ),
            // If the crop is already added, show a 'Added' overlay
            if (isAdded)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: Text(
                    'Added',
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
    );
  }
}
