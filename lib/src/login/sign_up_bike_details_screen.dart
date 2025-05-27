import 'package:flutter/material.dart';
import 'package:poppflutter/src/login/model/user_data_model.dart';
import 'package:poppflutter/src/login/register_and_subscribe_screen.dart';
import 'package:poppflutter/src/utils/build_extensions.dart';

class SignUpBikeDetailsScreen extends StatefulWidget {
  final UserData userData;

  const SignUpBikeDetailsScreen({super.key, required this.userData});

  @override
  State<SignUpBikeDetailsScreen> createState() =>
      _SignUpBikeDetailsScreenState();
}

class _SignUpBikeDetailsScreenState extends State<SignUpBikeDetailsScreen> {
  final List<Map<String, TextEditingController>> bikes = List.generate(
    3,
    (_) => {
      'brand': TextEditingController(),
      'model': TextEditingController(),
      'monthYear': TextEditingController(),
    },
  );

  void goToRegisterAndSubscribeScreen() {
    final bikeList = bikes
        .map((bike) => BikeData(
              brand: bike['brand']!.text,
              model: bike['model']!.text,
              monthYear: bike['monthYear']!.text,
            ))
        .where((b) =>
            b.brand.isNotEmpty || b.model.isNotEmpty || b.monthYear.isNotEmpty)
        .toList();

    final updatedUserData = widget.userData.copyWith(bikes: bikeList);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            RegisterAndSubscribeScreen(userData: updatedUserData),
      ),
    );
  }

  Widget buildBikeFields(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bike ${index + 1} Details:',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green)),
        const SizedBox(height: 10),
        buildInputField(
            'Bike Brand', 'Enter Bike Brand name', bikes[index]['brand']!),
        buildInputField(
            'Bike Model', 'Enter Bike Model name', bikes[index]['model']!),
        buildInputField('MFG Month/Year', 'Enter Month and year of MFG',
            bikes[index]['monthYear']!),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget buildInputField(
      String label, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: context.inputDecoration(label, hint),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bike Details')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Please enter Bikes details you own for custom notifications',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '(This step is optional. You can skip if you don’t own a bike.)',
                      style: TextStyle(
                          fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 3,
                      itemBuilder: (context, index) => buildBikeFields(index),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: goToRegisterAndSubscribeScreen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const StadiumBorder(),
                ),
                child: const Text("Next",
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
