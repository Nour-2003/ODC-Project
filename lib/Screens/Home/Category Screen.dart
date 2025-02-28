import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:odc_project/Screens/Home/Home%20Page.dart';
import 'package:sizer/sizer.dart';
import '../../Cubit/Shop/Shop Cubit.dart';
import '../../Cubit/Shop/Shop States.dart';
import '../../Shared/Constants.dart';
class CategoryScreen extends StatelessWidget {
  final String categoryName;

  CategoryScreen({required this.categoryName});

  @override
  Widget build(BuildContext context) {
    var cubit = BlocProvider.of<ShopCubit>(context); // Access ShopCubit instance

    if (cubit.selectedCategory != categoryName) {
      cubit.selectCategory(categoryName);
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(categoryName,style: GoogleFonts.montserrat(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),),
        backgroundColor: defaultcolor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: defaultcolor,
          statusBarIconBrightness: Brightness.light,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body: BlocConsumer<ShopCubit, ShopStates>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is ShopLoadingCatProductsDataState) {
            return Center(
              child: CircularProgressIndicator(
                color: defaultcolor,
              ),
            );
          }

          if (cubit.categoryProducts.isEmpty) {
            return Center(
              child: Text(
                'No products found in $categoryName',
                style: TextStyle(fontSize: 18),
              ),
            );
          }
          return SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child:ProductsListBuilder(cubit.categoryProducts, cubit),
            ),
          );
        },
      ),
    );
  }
}
