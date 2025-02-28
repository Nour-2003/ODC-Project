import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:odc_project/Shared/Constants.dart';
import 'package:sizer/sizer.dart';
import '../../Cubit/Shop/Shop Cubit.dart';
import '../../Cubit/Shop/Shop States.dart';
import '../../Cubit/Theme/Theme Cubit.dart';
import 'Show Order Page.dart';


class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  Widget _buildCartItem(BuildContext context, DocumentSnapshot<Object?> item) {
    final data = item.data() as Map<String, dynamic>? ?? {};

    return FadeInLeft(
      duration: const Duration(milliseconds: 500),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CachedNetworkImage(
                  imageUrl:data['imageUrl'] ?? '',
                  width: 10.h,
                  height: 10.h,
                    fit: BoxFit.contain,
                  placeholder: (context, url) => SpinKitCircle(
                    color: defaultcolor,
                    size: 50.0,
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'] ?? '',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '\$${data['price'] ?? '0.00'}',
                            style: GoogleFonts.montserrat(
                              color: ThemeCubit.get(context).themebool ? Colors.white : Colors.black,
                              fontSize: 18.sp,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                      child: Container(
                                        height: 4.h,
                                        width: 4.h,
                                        decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10),
                                            )
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.remove, size: 16,color: Colors.black,),
                                          onPressed: () {
                                            final currentQuantity = data['quantity'] ?? 1;
                                            if (currentQuantity > 1) {
                                              FirebaseFirestore.instance
                                                  .collection('Cart')
                                                  .doc(item.id)
                                                  .update({'quantity': currentQuantity - 1});
                                              ShopCubit.get(context).getCartData();
                                            }
                                          },
                                          constraints: const BoxConstraints(
                                            minWidth: 32,
                                            minHeight: 32,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${data['quantity'] ?? 1}',
                                      style: GoogleFonts.montserrat(fontSize: 14.sp,
                                      color:  Colors.black),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                      child: Container(
                                        height: 4.h,
                                        width: 4.h,
                                        decoration: BoxDecoration(
                                            color: defaultcolor,
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(10),
                                            )
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.add, size: 16,color: Colors.white,),
                                          onPressed: () {
                                            final currentQuantity = data['quantity'] ?? 1;
                                            FirebaseFirestore.instance
                                                .collection('Cart')
                                                .doc(item.id)
                                                .update({'quantity': currentQuantity + 1});
                                            ShopCubit.get(context).getCartData();
                                          },
                                          constraints: const BoxConstraints(
                                            minWidth: 32,
                                            minHeight: 32,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateTotal(List<DocumentSnapshot<Object?>> items) {
    return items.fold<double>(
      0,
          (sum, item) {
        final data = item.data() as Map<String, dynamic>? ?? {};
        final price = (double.parse(data['price']) ?? 0);
        final quantity = (data['quantity'] ?? 1).toInt();
        return sum + (price * quantity);
      },
    );
  }

  List<Map<String, dynamic>> _prepareOrderItems(List<DocumentSnapshot<Object?>> items) {
    return items.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return {
        'id': doc.id,
        'title': data['title'] ?? '',
        'price': data['price'] ?? 0,
        'quantity': data['quantity'] ?? 1,
        'imageUrl': data['imageUrl'] ?? '',
      };
    }).toList();
  }

  Widget _buildCheckoutSection(BuildContext context, List<DocumentSnapshot<Object?>> items) {
    final total = _calculateTotal(items);

    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          color: ThemeCubit.get(context).themebool ? Colors.grey[800] : Colors.white,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text(
                  'Total:',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShowOrderPage(
                      orderItems: _prepareOrderItems(items),
                      orderTotal: total,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(70),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child:  Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: const Color(0xffFFFFFF),
                        ),
                        width: 50,
                        height: 50,
                        child: const FaIcon(
                          FontAwesomeIcons.angleDoubleRight,
                          size: 23,
                          color: Colors.black,
                        )
                    ),
                  ),
                  Padding(
                    padding:  EdgeInsets.only(left: 20.w),
                    child: Text(
                      'Checkout',
                      style: GoogleFonts.montserrat(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShopCubit, ShopStates>(
      listener: (context, state) {
        // Handle state changes if needed
      },
      builder: (context, state) {
        var cubit = ShopCubit.get(context);
        final items = cubit.CartItems.cast<DocumentSnapshot<Object?>>();

        if (state is GetCartData) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          // appBar: AppBar(
          //   title: const Text('Shopping Cart'),
          //   elevation: 0,
          //   centerTitle: true,
          // ),
          body: items.isEmpty
              ? Center(
            child: Text(
              'Your cart is Empty',
              style: GoogleFonts.montserrat(fontSize: 18,),
            ),
          )
              : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) => Dismissible(
                    onDismissed: (direction) {
                      FirebaseFirestore.instance
                          .collection('Cart')
                          .doc(items[index].id)
                          .delete();
                      ShopCubit.get(context).getCartData();
                    },
                      background: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(right: 16),
                        decoration:  BoxDecoration(
                          color: defaultcolor,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      key: Key(items[index].id.toString()),
                      child: _buildCartItem(context, items[index])),
                ),
              ),
              _buildCheckoutSection(context, items),
            ],
          ),
        );
      },
    );
  }
}