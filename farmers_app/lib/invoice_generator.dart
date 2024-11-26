import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

Future<void> generateInvoice(int farmerId, BuildContext context) async {
  try {
    final pdf = pw.Document();

    final notoFont = await rootBundle.load("assets/NotoSans-Regular.ttf");
    final notoTtf = pw.Font.ttf(notoFont);

    final defaultTextStyle = pw.TextStyle(fontFallback: [notoTtf]);

    final farmerResponse = await http.get(
      Uri.parse('http://192.168.1.4:5000/get_farmer/$farmerId'),
    );

    if (farmerResponse.statusCode != 200) {
      throw Exception('Failed to fetch farmer details.');
    }

    final farmerData = jsonDecode(farmerResponse.body);

    final cropsResponse = await http.get(
      Uri.parse('http://192.168.1.4:5000/get_crops/$farmerId'),
    );

    if (cropsResponse.statusCode != 200) {
      throw Exception('Failed to fetch crop details.');
    }

    final cropsData = List<Map<String, dynamic>>.from(jsonDecode(cropsResponse.body));

    final droneUsageResponse = await http.get(
      Uri.parse('http://192.168.1.4:5000/get_drone_usage/$farmerId'),
    );

    if (droneUsageResponse.statusCode != 200) {
      throw Exception('Failed to fetch drone usage details.');
    }

    final droneUsageData = jsonDecode(droneUsageResponse.body);

    final logoImage = pw.MemoryImage(
      (await rootBundle.load('assets/logo2.png')).buffer.asUint8List(),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(logoImage, width: 100, height: 100),
                  pw.Text('Invoice', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(width: 100),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Paragraph(text: 'Farmer Details:', style: defaultTextStyle),
            pw.Table.fromTextArray(
              headers: ['Name', 'Mobile Number', 'Address'],
              data: [
                [farmerData['name'], farmerData['mobile'], farmerData['address']],
              ],
              cellStyle: defaultTextStyle,
            ),
            pw.SizedBox(height: 20),
            pw.Paragraph(text: 'Crop and Product Details:', style: defaultTextStyle),
            pw.Table.fromTextArray(
              headers: ['Crop Name', 'Total Acreage', 'Drone Usage Acreage', 'Product Name and Quantity'],
              data: cropsData.map((crop) => [
                    crop['crop_name'],
                    crop['total_acreage'].toString(),
                    crop['drone_usage_acreage'].toString(),
                    crop['products_used'],
                  ]).toList(),
              cellStyle: defaultTextStyle,
            ),
            pw.SizedBox(height: 20),
            pw.Paragraph(text: 'Drone Usage Summary:', style: defaultTextStyle),
            pw.Table.fromTextArray(
              headers: ['Total Drone Usage Acreage', 'Per Acre Charge', 'Total Amount'],
              data: [
                [
                  droneUsageData['total_drone_usage_acreage'].toString(),
                  'INR 200',
                  'INR ${droneUsageData['total_amount'].toStringAsFixed(2)}',
                ],
              ],
              cellStyle: defaultTextStyle,
            ),
          ];
        },
      ),
    );

    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/invoice.pdf');
    await file.writeAsBytes(await pdf.save());

    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => await pdf.save(),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open PDF: $e'),
            duration: const Duration(seconds: 3),
          ),
        );

      }

      
    }

    if (context.mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice generated successfully.'),
            duration: Duration(seconds: 3),
          ),
        );
    }

    
  } catch (e) {
    if (context.mounted){

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate invoice: $e'),
          duration: const Duration(seconds: 3),
        ),
      );

    }
    
  }
}