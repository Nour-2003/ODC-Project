import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:sizer/sizer.dart';

import '../../Cubit/Shop/Shop Cubit.dart';
import '../../Cubit/Shop/Shop States.dart';
import '../../Cubit/Theme/Theme Cubit.dart';
import '../../Shared/Constants.dart';

class ProductDetails extends StatefulWidget {
  final String productId;
  late String title;
  final String imageUrl;
  late String description;
  late String price;
  final String rating;
  final String reviews;
  late String category;
  final String role;

  ProductDetails({
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.category,
    required this.role,
    Key? key,
  }) : super(key: key);

  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<ShopCubit>(context);
    print(cubit.firebaseProducts.length);
    return BlocBuilder<ShopCubit, ShopStates>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              'Product Details',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 22,
              ),
            ),
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
            centerTitle: true,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        child: (widget.imageUrl.isNotEmpty)
                            ? CachedNetworkImage(
                                height: double.infinity,
                                width: double.infinity,
                                fit: BoxFit.contain,
                                imageUrl: widget.imageUrl,
                                placeholder: (context, url) => SpinKitCircle(
                                  color: defaultcolor,
                                  size: 50,
                                ),
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  "Images/placeholder.png",
                                  fit: BoxFit.contain,
                                ),
                              )
                            : Image.asset(
                                "Images/placeholder.png",
                                fit: BoxFit.contain,
                              ),
                      ),
                      // Gradient overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 80,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Theme.of(context).scaffoldBackgroundColor,
                                Theme.of(context)
                                    .scaffoldBackgroundColor
                                    .withOpacity(0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.title,
                              style: GoogleFonts.montserrat(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              '\$${widget.price}',
                              style: GoogleFonts.montserrat(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.3.h),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.category,
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 1.3.h),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: List.generate(
                                5,
                                (index) => Icon(
                                  index < double.parse(widget.rating)
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  color: Colors.amber,
                                  size: 24,
                                ),
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              '${widget.rating} (${widget.reviews} reviews)',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.amber[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.h),

                      Text(
                        'Description',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .shadowColor
                                  .withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isExpanded
                                  ? widget.description
                                  : '${widget.description.substring(0, widget.description.length > 100 ? 100 : widget.description.length)}...',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _isExpanded = !_isExpanded),
                              child: Row(
                                children: [
                                  Text(
                                    _isExpanded ? 'See Less' : 'See More',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Icon(
                                    _isExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 3.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            cubit
                                .addToCart(
                              widget.title,
                              widget.price,
                              widget.description,
                              widget.category,
                              widget.imageUrl,
                              widget.rating,
                              widget.reviews,
                            )
                                .then((value) {
                              if (context.mounted) {
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.success,
                                  animType: AnimType.bottomSlide,
                                  title: 'Success',
                                  desc: 'Product added to cart successfully',
                                  btnOkOnPress: () {},
                                  titleTextStyle: GoogleFonts.montserrat(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeCubit.get(context).themebool
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  descTextStyle: GoogleFonts.montserrat(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeCubit.get(context).themebool
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  dialogBackgroundColor:
                                      ThemeCubit.get(context).themebool
                                          ? Colors.grey[800]
                                          : Colors.white,
                                ).show();
                              }
                            });
                          },
                          icon: const Icon(Icons.shopping_cart_outlined,
                              size: 24),
                          label: Text(
                            'Add to Cart',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "Similar Products",
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      SimilarProducts(cubit, widget.category, widget.title)
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget SimilarProducts(cubit, category, title) {
  return SizedBox(
    height: 350,
    child: ListView.builder(
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal, // Horizontal scrolling
      itemCount: cubit.firebaseProducts
          .where((product) =>
              (product['category'] == category && product['title'] != title))
          .length,
      itemBuilder: (context, index) {
        final filteredProducts = cubit.firebaseProducts
            .where((product) =>
                (product['category'] == category && product['title'] != title))
            .toList();
        final product = filteredProducts[index];
        return Container(
          width: 240,
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: product['imageUrl'],
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Center(
                          child: SpinKitCircle(
                            color: defaultcolor,
                            size: 50,
                          ),
                        ),
                        errorWidget: (context, url, error) => Center(
                          child: Image.asset(
                            "Images/placeholder.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.2), // Dark overlay
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
                color: ThemeCubit.get(context).themebool
                    ? Colors.black
                    : Colors.white,
                elevation: 5, // Shadow
                child: Padding(
                  padding: EdgeInsets.all(2.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        product['title'],
                        maxLines: 2,
                        style: GoogleFonts.montserrat(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        product['description'],
                        maxLines: 2,
                        style: GoogleFonts.montserrat(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        '\$${product['price']}',
                        style: GoogleFonts.montserrat(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Row(
                                    children: List.generate(
                                      5,
                                      (starIndex) => Icon(
                                        starIndex <
                                                double.parse(product[
                                                    'rating']) // Dynamic rating
                                            ? Icons.star_rounded
                                            : Icons.star_outline_rounded,
                                        color: Colors.amber,
                                        size: 17.sp,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    "${product['rating']}",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
