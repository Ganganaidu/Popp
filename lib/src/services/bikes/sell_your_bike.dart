import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:poppflutter/src/services/bikes/seller_bike_details_form.dart';

import '../../widgets/image_picker_selection.dart';

class SellYourBike extends StatefulWidget {
  const SellYourBike({super.key});

  @override
  State<SellYourBike> createState() => _SellYourBikeState();
}

class _SellYourBikeState extends State<SellYourBike> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController sellerNameController = TextEditingController();
  final TextEditingController sellerContactController = TextEditingController();
  final TextEditingController modelNameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final List<XFile> _images = [];

  String selectedCountryCode = "+91";
  String? selectedBrand;
  String? selectedState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Strictly Only 35+ HP/NM Powered Bikes",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              SellerBikeDetailsForm(
                sellerNameController: sellerNameController,
                sellerContactController: sellerContactController,
                modelNameController: modelNameController,
                cityController: cityController,
                selectedBrand: selectedBrand,
                selectedState: selectedState,
                selectedCountryCode: selectedCountryCode,
                onCountryCodeChanged: (val) =>
                    setState(() => selectedCountryCode = val),
                onBrandChanged: (val) => setState(() => selectedBrand = val),
                onStateChanged: (val) => setState(() => selectedState = val),
              ),
              const SizedBox(height: 16.0),
              ImagePickerSection(
                images: _images,
                onImagesChanged: (imgs) {
                  setState(() {
                    _images.clear();
                    _images.addAll(imgs);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
