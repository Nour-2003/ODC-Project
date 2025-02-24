import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Cubit/Shop/Shop Cubit.dart';
import '../../Cubit/Shop/Shop States.dart';
import '../../Cubit/Theme/Theme Cubit.dart';

class EditCategoryScreen extends StatelessWidget {
  final String categoryName;
  final String id;

  EditCategoryScreen({required this.categoryName, required this.id});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShopCubit, ShopStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Category'),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: nameController,
                    style: GoogleFonts.montserrat(color:  ThemeCubit.get(context).themebool ? Colors.white: Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Category Name',
                      labelStyle: GoogleFonts.montserrat(color:  ThemeCubit.get(context).themebool ? Colors.white: Colors.black,fontWeight: FontWeight.bold),
                      hintText: categoryName,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value != null && value.trim().isEmpty && imageController.text.trim().isEmpty) {
                        return 'Please enter a value for at least one field.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: imageController,
                    style: GoogleFonts.montserrat(color:  ThemeCubit.get(context).themebool ? Colors.white: Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Category Image',
                      labelStyle:GoogleFonts.montserrat(color:  ThemeCubit.get(context).themebool ? Colors.white: Colors.black,fontWeight: FontWeight.bold),
                      hintText: 'Enter image URL',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value != null && value.trim().isEmpty && nameController.text.trim().isEmpty) {
                        return 'Please enter a value for at least one field.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isEmpty && imageController.text.isEmpty) {
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.warning,
                          animType: AnimType.rightSlide,
                          title: 'Validation Error',
                          desc: 'Please enter a value for at least one field.',
                          btnOkOnPress: () {},
                        ).show();
                      } else if (formKey.currentState!.validate()) {
                        ShopCubit.get(context).updateCategoryAndProducts(
                          categoryName,
                          nameController.text,
                          imageController.text,
                        ).then((value) {
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.success,
                            animType: AnimType.rightSlide,
                            title: 'Success',
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
                            desc: 'Category has been updated successfully.',
                            btnOkOnPress: () {
                              Navigator.pop(context);
                            },
                          ).show();
                        });
                      }
                    },
                    child:Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text('Edit Category',style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
