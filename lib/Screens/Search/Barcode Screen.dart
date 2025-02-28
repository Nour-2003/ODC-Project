
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sizer/sizer.dart';
import '../../Cubit/Shop/Shop Cubit.dart';
import '../../Cubit/Shop/Shop States.dart';
import '../../Shared/Constants.dart';
import '../Home/Product Details Screen.dart';

class BarcodeScreen extends StatefulWidget {
  const BarcodeScreen({super.key,required this.role});
  final String role;
  @override
  State<BarcodeScreen> createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends State<BarcodeScreen> {
  MobileScannerController controller = MobileScannerController();
  bool _screenOpened = false;
  bool isTorchOn = false;
  bool isFrontCamera = false;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopCubit,ShopStates>(
      builder: (context,state){
        return Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(
                color: Colors.white,
              ),
              elevation: 10,
              centerTitle: true,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.white,
                statusBarIconBrightness: Brightness.dark,
              ),
              title:Text('Barcode Search',style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),),
              backgroundColor: defaultcolor,
              actions: [
                // Torch Toggle Button
                IconButton(
                  onPressed: () {
                    setState(() {
                      isTorchOn = !isTorchOn; // Toggle torch state
                      controller.toggleTorch(); // Add your torch toggle logic here
                    });
                  },
                  iconSize: 30,
                  color: Colors.white,
                  icon: Icon(isTorchOn ? Icons.flash_on : Icons.flash_off),
                ),
                // Camera Toggle Button
                IconButton(
                  onPressed: () {
                    setState(() {
                      isFrontCamera = !isFrontCamera; // Toggle camera state
                      controller.switchCamera(); // Add your camera toggle logic here
                    });
                  },
                  iconSize: 30,
                  color: Colors.white,
                  icon: Icon(isFrontCamera ? Icons.camera_front : Icons.camera_rear),
                ),
              ],
            ),
            body:MobileScanner(
                controller: controller,
                onDetect: (BarcodeCapture capture) async {
                  final List<Barcode> barcodes = capture.barcodes;

                  if (!_screenOpened) {
                    for (final barcode in barcodes) {
                      final String code = barcode.rawValue ?? "---";
                      debugPrint("Barcode detected: $code");

                      try {
                        final productDoc = await FirebaseFirestore.instance
                            .collection('Products')
                            .doc(code)
                            .get();

                        if (productDoc.exists) {
                          final productData = productDoc.data();
                          _screenOpened = true;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetails(
                                productId: productDoc.id,
                                title: productData?['title'] ?? '',
                                imageUrl: productData?['imageUrl'] ?? '',
                                description: productData?['description'] ?? '',
                                price: productData?['price'] ?? '',
                                rating: productData?['rating'] ?? '',
                                reviews: productData?['reviews'] ?? '',
                                category: productData?['category'] ?? '',
                                role: widget.role, // Pass the role based on the current user
                              ),
                            ),
                          );
                        } else {
                          debugPrint("No product found for barcode: $code");
                          // Handle no product found (e.g., show an alert dialog)
                          // Show an appropriate message to the user
                        }
                      } catch (e) {
                        debugPrint("Error retrieving product: $e");
                        // Handle errors (e.g., network or permission issues)
                        // Show an error message to the user
                      }
                    }
                  }
                }

            )

        );
      },
    );
  }
  void _screenWasClosed()
  {
    _screenOpened = false;
  }
}
class FoundCodeScreen extends StatefulWidget {
  final String value;
  final Function() screenClosed;
  final Map<String, dynamic>? productData; // Accept the product data

  const FoundCodeScreen({
    Key? key,
    required this.value,
    required this.screenClosed,
    this.productData,
  }) : super(key: key);

  @override
  State<FoundCodeScreen> createState() => _FoundCodeScreenState();
}

class _FoundCodeScreenState extends State<FoundCodeScreen> {
  @override
  Widget build(BuildContext context) {
    final product = widget.productData;

    return Scaffold(
      appBar: AppBar(
        title: Text("Found Code"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            widget.screenClosed();
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Found Code: ${widget.value}",
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            product != null
                ? Text(
              "Product Name: ${product['title']}\nPrice: ${product['price']}",
              style: TextStyle(fontSize: 18),
            )
                : Text(
              "No product details available.",
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
