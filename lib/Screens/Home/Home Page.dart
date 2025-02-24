import 'package:animate_do/animate_do.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../Cubit/Shop/Shop Cubit.dart';
import '../../Cubit/Shop/Shop States.dart';
import '../../Cubit/Theme/Theme Cubit.dart';
import '../../Shared/Constants.dart';
import 'Category Screen.dart';
import 'Product Details Screen.dart';

class HomePage extends StatelessWidget {
  List Data = [];

  List categories = [];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShopCubit, ShopStates>(
      listener: (context, state) {
        if (state is ProductUpdatedSuccessState) {
          ShopCubit.get(context).getData();
        }
      },
      builder: (context, state) {
        var cubit = ShopCubit.get(context);
        var data = cubit.firebaseProducts;
        var categories = cubit.firebaseCategories;
        print("Fire Base Data Here " + data.length.toString());

        return Scaffold(
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   SizedBox(height: 1.h),
                  FadeInLeft(
                    duration: const Duration(milliseconds: 500),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('All Featured',
                          style: GoogleFonts.montserrat(
                              fontSize: 25, fontWeight: FontWeight.bold)),
                    ),
                  ),
                   SizedBox(height: 2.h),
                  FadeInLeft(
                    duration: const Duration(milliseconds: 500),
                    child: ConditionalBuilder(
                      condition: categories.isNotEmpty,
                      fallback: (context) => Center(
                        child: CircularProgressIndicator(
                          color: defaultcolor,
                        ),
                      ),
                      builder: (context) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h), // Responsive padding
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: ThemeCubit.get(context).themebool
                                ? Colors.grey.withOpacity(0.1)
                                : Colors.white,
                          ),
                          height: 17.h, // Fixed height (17% of screen height)
                          child: ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) => GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) =>
                                        CategoryScreen(
                                          role: cubit.userData?['role'],
                                          categoryName: categories[index]['name'],
                                          id: categories[index].id,
                                        ),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      const begin = Offset(1.0, 0.0); // Start from right
                                      const end = Offset.zero; // End at the current position
                                      const curve = Curves.easeInOut; // Smooth curve

                                      var tween = Tween(begin: begin, end: end)
                                          .chain(CurveTween(curve: curve));
                                      var offsetAnimation = animation.drive(tween);

                                      return SlideTransition(
                                        position: offsetAnimation,
                                        child: child,
                                      );
                                    },
                                  ),
                                ).then((_) {
                                  cubit.getCategories();
                                });
                              },
                              child: Column(
                                children: [
                                  // Category Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: CachedNetworkImage(
                                      imageUrl: categories[index]['imageUrl'],
                                      fit: BoxFit.cover,
                                      width: 22.w, // Responsive width (15% of screen width)
                                      height: 22.w, // Responsive height (same as width for a square)
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
                                  SizedBox(height: 1.h), // Responsive spacing
                                  // Category Name
                                  Text(
                                    categories[index]['name'],
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13.sp, // Responsive font size
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            separatorBuilder: (context, index) => SizedBox(width: 5.w), // Responsive spacing
                            itemCount: categories.length,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 25),
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('Top Products',
                          style: GoogleFonts.montserrat(
                              fontSize: 25, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      child: ProductsListBuilder(data, cubit)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget ProductsListBuilder(data, cubit) => ConditionalBuilder(
      condition: data.isNotEmpty,
      fallback: (context) => Center(
        child: CircularProgressIndicator(
          color: defaultcolor,
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisSpacing: 2.w,
              childAspectRatio: (105.w / 2) / (50.h),
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 100.w < 600 ? 2 : 3,
              children: List.generate(data.length, (index) {
                return GestureDetector(
                  onTap: () {
                    String role = cubit.userData?['role'] ?? 'user';
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                          value: BlocProvider.of<ShopCubit>(context), // Pass the same instance
                          child: ProductDetails(
                            role: role,
                            productId: data[index].id,
                            title: data[index]['title'],
                            imageUrl: data[index]['imageUrl'],
                            description: data[index]['description'],
                            price: data[index]['price'],
                            rating: data[index]['rating'],
                            reviews: data[index]['count'],
                            category: data[index]['category'],
                          ),
                        ),
                      ),
                    );

                  },
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: ThemeCubit.get(context).themebool
                              ? Colors.grey[900]
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          content: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            constraints: const BoxConstraints(
                              maxHeight: 400,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(
                                          15), // Consistent rounded corners
                                    ),
                                    child: Container(
                                      width: double.infinity,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        // Placeholder background color
                                        borderRadius: BorderRadius.circular(
                                            15), // Match the ClipRRect border radius
                                      ),
                                      child: CachedNetworkImage(
                                        imageUrl: data[index]['imageUrl'],
                                        fit: BoxFit.contain,
                                        // Ensures the image covers the entire container
                                        placeholder: (context, url) => Center(
                                          child: SpinKitCircle(
                                            color: defaultcolor,
                                            size: 50,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Center(
                                          child: Image.asset(
                                            "Images/placeholder.png",
                                            fit: BoxFit
                                                .cover, // Ensures the placeholder image also covers the container
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Category: ${data[index]['category']}",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      color:  ThemeCubit.get(context).themebool ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "Price: \$${data[index]['price']}",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "Rating: ${data[index]['rating']} (${data[index]['count']} reviews)",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      color: Colors.amber,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    data[index]['description'],
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      color: ThemeCubit.get(context).themebool ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Close",
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(
                                    15), // Consistent rounded corners
                              ),
                              child: Container(
                                width: double.infinity,
                                // Ensures the image takes the full width available
                                height: 24.h,
                                // Fixed height for consistency
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  // Placeholder background color
                                  borderRadius: BorderRadius.circular(
                                      15), // Match the ClipRRect border radius
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: data[index]['imageUrl'],
                                  fit: BoxFit.cover,
                                  // Ensures the image covers the entire container
                                  placeholder: (context, url) => Center(
                                    child: SpinKitCircle(
                                      color: defaultcolor,
                                      size: 50,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Center(
                                    child: Image.asset(
                                      "Images/placeholder.png",
                                      fit: BoxFit
                                          .cover, // Ensures the placeholder image also covers the container
                                    ),
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
                                      Colors.black.withOpacity(0.2),
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
                        color: ThemeCubit.get(context).themebool ? Colors.black : Colors.white,
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title with enhanced typography
                              Text(
                                "${data[index]['title']}",
                                maxLines: 2,
                                style: GoogleFonts.montserrat(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  height: 1.2,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                "${data[index]['category']}",
                                style: GoogleFonts.montserrat(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                               SizedBox(height: 1.h),
                              Text(
                                "\$${data[index]['price']}",
                                style: GoogleFonts.montserrat(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                               SizedBox(height: 1.2.h),
                              // Enhanced Rating Display
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Row(
                                            children: List.generate(
                                              5,
                                              (starIndex) => Icon(
                                                starIndex <
                                                        double.parse(
                                                            data[index]
                                                                ['rating'])
                                                    ? Icons.star_rounded
                                                    : Icons
                                                        .star_outline_rounded,
                                                color: Colors.amber,
                                                size: 17.sp,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 1.w),
                                          Text(
                                            "${data[index]['rating']}",
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
              }),
            ),
          ),
        );
      },
    );

Widget Category(categories, index) {
  return Stack(
    children: [
      ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Hero(
            tag: 'category_${categories[index]['name']}',
            child: (categories[index]['imageUrl'] != null &&
                    categories[index]['imageUrl'].isNotEmpty)
                ? FadeInImage.assetNetwork(
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: "Images/Animation - 1734121167586.gif",
                    image: categories[index]['imageUrl'],
                    imageErrorBuilder: (context, error, stackTrace) =>
                        Image.asset("Images/placeholder.png"),
                    fadeInDuration: const Duration(milliseconds: 300),
                    fadeInCurve: Curves.easeInOut,
                  )
                : Image.asset(
                    "Images/placeholder.png",
                    fit: BoxFit.cover,
                  ),
          ),
        ),
      ),
      // Enhanced gradient overlay
      Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
              stops: const [0.5, 1.0],
            ),
          ),
        ),
      ),
      // Enhanced text container
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            categories[index]['name'],
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              shadows: [
                const Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 2,
                  color: Colors.black26,
                ),
              ],
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ],
  );
}
