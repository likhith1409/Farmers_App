import 'package:flutter/material.dart';
import 'home_section.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Represents the screen where farmers can enter and submit their details.
///
/// This widget allows farmers to input their name, mobile number, and address,
/// and then submit this information to the server for registration. Upon successful
/// registration, the user is navigated to the HomeSection screen.
///

class FarmerDetails extends StatefulWidget {
  const FarmerDetails({super.key});

  @override
  State<FarmerDetails> createState() => _FarmerDetailsState();
}

class _FarmerDetailsState extends State<FarmerDetails> {
  final TextEditingController _farmerNameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FEFA),
      appBar: AppBar(
        title: const Center(
          child: Image(
            image: AssetImage('assets/logo2.png'),
            height: 40,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/profile_icon.png'),
              ),
              const SizedBox(height: 20),
              _buildLabeledInputField('Farmer Name', false, _farmerNameController),
              const SizedBox(height: 10),
              _buildLabeledInputField('Mobile Number', true, _mobileNumberController),
              const SizedBox(height: 10),
              _buildLabeledInputField('Address', false, _addressController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final farmerName = _farmerNameController.text;
                  final mobileNumber = _mobileNumberController.text;
                  final address = _addressController.text;

                  // Send the farmer details to the server for registration
                  final response = await http.post(
                    Uri.parse('http://192.168.1.4:5000/register_farmer'),
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: jsonEncode(<String, String>{
                      'name': farmerName,
                      'mobile': mobileNumber,
                      'address': address,
                    }),
                  );

                  if (response.statusCode == 201) {
                    final responseData = jsonDecode(response.body);
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeSection(farmerId: responseData['farmer_id']),
                        ),
                      );

                    }
                    
                  } else {
                      if (context.mounted){
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to register farmer')),
                        );
                      }
                    
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E8059),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    'Register',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text.rich(
                TextSpan(
                  text: 'Already a user? ',
                  children: [
                    TextSpan(
                      text: 'Login here',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a labeled input field with a hint text and optional numeric keyboard.
  ///
  /// Parameters:
  /// - label: The label text for the input field.
  /// - isNumeric: Whether the input field should use a numeric keyboard.
  /// - controller: The TextEditingController for the input field.
  Widget _buildLabeledInputField(String label, bool isNumeric, TextEditingController controller) {
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
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.black),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
