import 'package:animate_do/animate_do.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:odc_project/Shared/Constants.dart';
import 'package:odc_project/main.dart';
import 'package:sizer/sizer.dart';

import '../../Cubit/Theme/Theme Cubit.dart';

class ShowOrderPage extends StatelessWidget {
  final List<Map<String, dynamic>> orderItems;
  final double orderTotal;
  double? finalRating;

  ShowOrderPage({
    Key? key,
    required this.orderItems,
    required this.orderTotal,
  }) : super(key: key);

  Widget _buildOrderItem(Map<String, dynamic> item) {
    final double price = (double.parse(item['price']) ?? 0);
    final int quantity = (item['quantity'] ?? 1).toInt();
    final double total = price * quantity;

    return FadeInLeft(
      duration: const Duration(milliseconds: 500),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl:
                        item['imageUrl'] ?? '',
                        width: 12.h,
                        height: 12.h,
                        fit: BoxFit.contain,
                      placeholder: (context, url) => SpinKitCircle(
                        color: defaultcolor,
                        size: 30,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['title'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2.5.h),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          alignment: Alignment.center,
                          width: 23.w,
                          height: 5.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '\$${price.toStringAsFixed(2)}',
                            style: GoogleFonts.montserrat(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Divider(
                thickness: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Order ($quantity) :',
                    style: GoogleFonts.montserrat(
                      fontSize: 14.sp,
                    ),
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: GoogleFonts.montserrat(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitOrder(BuildContext context) async {
    try {
      final orderRef = FirebaseFirestore.instance.collection('Orders');
      final newOrder = await orderRef.add({
        'items': orderItems,
        'total': orderTotal.toStringAsFixed(2),
        'status': 'pending',
        'rating': 0,
        'timestamp': FieldValue.serverTimestamp(),
      });

      for (var item in orderItems) {
        item['orderId'] = newOrder.id;
      }
      print("Order added with ID: ${newOrder.id}");

      final inventoryRef = FirebaseFirestore.instance.collection('Inventory');

      for (var item in orderItems) {
        final itemName = item['title'];
        final orderQuantity = item['quantity'];
        print("Processing item: $itemName, Quantity: $orderQuantity");

        final querySnapshot = await inventoryRef.where('name', isEqualTo: itemName).get();
        if (querySnapshot.docs.isNotEmpty) {
          print("Item exists in inventory. Updating quantity.");

          final docRef = querySnapshot.docs.first.reference;
          await docRef.update({
            'quantity': FieldValue.increment(orderQuantity),
          });
          print("Updated inventory for $itemName with quantity -$orderQuantity");
        } else {
          print("Item does not exist in inventory. Adding new item.");

          await inventoryRef.add({
            'name': itemName,
            'quantity': orderQuantity,
          });
          print("Added new inventory item: $itemName with quantity -$orderQuantity");
        }
      }

      final cartRef = FirebaseFirestore.instance.collection('Cart');
      final batch = FirebaseFirestore.instance.batch();

      for (var item in orderItems) {
        if (item['id'] != null) {
          final docRef = cartRef.doc(item['id']);
          batch.delete(docRef);
        }
      }

      await batch.commit();
      print("Cart updates committed.");
      LocalNotification.showBasicNotification();
      if (context.mounted) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: 'Order Submitted',
        btnOkOnPress: () {},
        desc: 'Your order has been submitted successfully!',
        titleTextStyle: GoogleFonts
            .montserrat(
          fontSize: 20,
          fontWeight:
          FontWeight
              .bold,
          color: ThemeCubit.get(context).themebool ? Colors.white:Colors.black,
        ),
        descTextStyle:GoogleFonts
            .montserrat(
          fontSize: 17,
          fontWeight:
          FontWeight
              .bold,
          color: ThemeCubit.get(context).themebool ? Colors.white:Colors.black,
        ) ,
        dialogBackgroundColor: ThemeCubit.get(context).themebool ? Colors.grey[800]:Colors.white,
      ).show();
      }
    } catch (e) {
      if (context.mounted) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: 'Error',
        btnOkOnPress: () {},
        desc: '$e',
        titleTextStyle: GoogleFonts
            .montserrat(
          fontSize: 20,
          fontWeight:
          FontWeight
              .bold,
          color: ThemeCubit.get(context).themebool ? Colors.white:Colors.black,
        ),
        descTextStyle:GoogleFonts
            .montserrat(
          fontSize: 17,
          fontWeight:
          FontWeight
              .bold,
          color: ThemeCubit.get(context).themebool ? Colors.white:Colors.black,
        ) ,
        dialogBackgroundColor: ThemeCubit.get(context).themebool ? Colors.grey[800]:Colors.white,
      ).show();
      }
    }
  }



  Future<void> _submitRating(BuildContext context) async {
    double? userRating;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ThemeCubit.get(context).themebool ? Colors.grey[800]:Colors.white,
          title:Text('Rate Your Order',style: GoogleFonts.montserrat(
            color: ThemeCubit.get(context).themebool ?Colors.white:Colors.black
          ),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               Text('How would you rate your order experience?',style: GoogleFonts.montserrat(
                  color: ThemeCubit.get(context).themebool ?Colors.white:Colors.black
               ),),
              const SizedBox(height: 16),
              RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  userRating = rating;
                  finalRating = rating;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:  Text('Cancel',style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),),
            ),
            ElevatedButton(
              onPressed: () async {
                if (userRating == null) {
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.warning,
                    animType: AnimType.bottomSlide,
                    title: 'No Rating Provided',
                    desc: 'Please provide a rating before submitting.',
                    btnOkOnPress: () {},
                    titleTextStyle: GoogleFonts
                        .montserrat(
                      fontSize: 20,
                      fontWeight:
                      FontWeight
                          .bold,
                      color: ThemeCubit.get(context).themebool ? Colors.white:Colors.black,
                    ),
                    descTextStyle:GoogleFonts
                        .montserrat(
                      fontSize: 17,
                      fontWeight:
                      FontWeight
                          .bold,
                      color: ThemeCubit.get(context).themebool ? Colors.white:Colors.black,
                    ) ,
                    dialogBackgroundColor: ThemeCubit.get(context).themebool ? Colors.grey[800]:Colors.white,
                  ).show();
                  return;
                }

                try {
                  if (orderItems.isEmpty || orderItems[0]['orderId'] == null) {
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.error,
                      animType: AnimType.bottomSlide,
                      title: 'Error',
                      desc: 'Order ID not found. Please try again.',
                      btnOkOnPress: () {},
                      titleTextStyle: GoogleFonts
                          .montserrat(
                        fontSize: 20,
                        fontWeight:
                        FontWeight
                            .bold,
                        color: ThemeCubit.get(context).themebool ? Colors.white:Colors.black,
                      ),
                      descTextStyle:GoogleFonts
                          .montserrat(
                        fontSize: 17,
                        fontWeight:
                        FontWeight
                            .bold,
                        color: ThemeCubit.get(context).themebool ? Colors.white:Colors.black,
                      ) ,
                      dialogBackgroundColor: ThemeCubit.get(context).themebool ? Colors.grey[800]:Colors.white,
                    ).show();
                    return;
                  }

                  final String orderId = orderItems[0]['orderId'];
                  final orderRef = FirebaseFirestore.instance.collection('Orders').doc(orderId);
                  await orderRef.update({'rating': userRating});

                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.success,
                    animType: AnimType.bottomSlide,
                    title: 'Rating Submitted',
                    desc: 'Thank you for rating your order!',
                    titleTextStyle: GoogleFonts
                        .montserrat(
                      fontSize: 20,
                      fontWeight:
                      FontWeight
                          .bold,
                      color: ThemeCubit.get(context).themebool ? Colors.white:Colors.black,
                    ),
                    descTextStyle:GoogleFonts
                        .montserrat(
                      fontSize: 17,
                      fontWeight:
                      FontWeight
                          .bold,
                      color: ThemeCubit.get(context).themebool ? Colors.white:Colors.black,
                    ) ,
                    dialogBackgroundColor: ThemeCubit.get(context).themebool ? Colors.grey[800]:Colors.white,
                    btnOkOnPress: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  ).show();
                } catch (e) {
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.error,
                    animType: AnimType.bottomSlide,
                    title: 'Error',
                    titleTextStyle: GoogleFonts
                        .montserrat(
                      fontSize: 20,
                      fontWeight:
                      FontWeight
                          .bold,
                      color: ThemeCubit.get(context).themebool ? Colors.white:Colors.black,
                    ),
                    descTextStyle:GoogleFonts
                        .montserrat(
                      fontSize: 17,
                      fontWeight:
                      FontWeight
                          .bold,
                      color: ThemeCubit.get(context).themebool ? Colors.white:Colors.black,
                    ) ,
                    dialogBackgroundColor: ThemeCubit.get(context).themebool ? Colors.grey[800]:Colors.white,
                    desc: 'An error occurred while submitting your rating. Please try again.\n\nError: $e',
                    btnOkOnPress: () {},
                  ).show();
                }
              },
              child:  Text('Submit',style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),),
            )

          ],
        );
      },
    );
  }

  Widget _buildSubmitSection(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          color: ThemeCubit.get(context).themebool ? Colors.grey[800] : Colors.white,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order:',
                  style: GoogleFonts.montserrat(
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '\$${orderTotal.toStringAsFixed(2)}',
                  style: GoogleFonts.montserrat(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            SizedBox(height: 1.5.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Shipping",style: GoogleFonts.montserrat(
                  color: ThemeCubit.get(context).themebool ?Colors.white:Colors.black,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),),
                Text(orderTotal > 2000 ? "Free" : "\$100",style: GoogleFonts.montserrat(
                  color: ThemeCubit.get(context).themebool ?Colors.white:Colors.black,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),),
              ],
            ),
            SizedBox(height: 1.5.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: GoogleFonts.montserrat(
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '\$${(orderTotal + (orderTotal > 2000 ? 0 : 100)).toStringAsFixed(2)}',
                  style: GoogleFonts.montserrat(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            ElevatedButton(
              onPressed: () => _submitOrder(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Submit Order',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _submitRating(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Rate Order',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: defaultcolor,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        title: Text('Checkout',style: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 22.0,
          fontWeight: FontWeight.bold,
        ),),
        elevation: 0,
        centerTitle: true,
      ),
      body: orderItems.isEmpty
          ? const Center(
        child: Text(
          'No items in your order',
          style: TextStyle(fontSize: 18),
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orderItems.length,
              itemBuilder: (context, index) =>
                  _buildOrderItem(orderItems[index]),
            ),
          ),
          _buildSubmitSection(context),
        ],
      ),
    );
  }
}
