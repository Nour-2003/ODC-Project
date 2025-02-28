import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:speech_to_text/speech_to_text.dart';

import '../../Cubit/Shop/Shop Cubit.dart';
import '../../Cubit/Shop/Shop States.dart';
import '../../Cubit/Theme/Theme Cubit.dart';
import '../../Shared/Constants.dart';
import '../Home/Home Page.dart';
import 'Barcode Screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final textController = TextEditingController();
  final SpeechToText speech = SpeechToText();
  bool speechEnabled = false;
  String lastWords = "";

  @override
  void initState() {
    super.initState();
    initSpeech();
    BlocProvider.of<ShopCubit>(context)
        .loadProducts(ShopCubit.get(context).firebaseProducts);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<ShopCubit>(context).searchProducts('');
    });
  }

  void initSpeech() async {
    speechEnabled = await speech.initialize();
    setState(() {});
  }

  void startListening(ShopCubit cubit) async {
    if (speechEnabled) {
      await speech.listen(onResult: onSpeechResult);
      setState(() {});
    }
  }

  void stopListening() async {
    await speech.stop();
    setState(() {
      lastWords = '';
    });
  }

  void onSpeechResult(result) {
    setState(() {
      lastWords = result.recognizedWords.trim(); // Get recognized speech
      textController.text =
          lastWords; // Update the text field with the speech result
      // Trigger search with the speech input
      BlocProvider.of<ShopCubit>(context).searchProducts(lastWords);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopCubit, ShopStates>(
      builder: (context, state) {
        var cubit = ShopCubit.get(context);

        return Scaffold(
          // appBar: AppBar(
          //   centerTitle: true,
          //   title: Text('Search Page'),
          // ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  FadeInLeft(
                    duration: const Duration(milliseconds: 500),
                    child: Row(
                      children: [
                        Expanded(
                          child: defaultTextFormField(
                            isDark: ThemeCubit.get(context).themebool,
                            textController: textController,
                            label: 'Search',
                            type: TextInputType.text,
                            prefixIcon: Icon(CupertinoIcons.search),
                            Validator: (value) {
                              if (value!.isEmpty) {
                                return 'Search must not be empty';
                              }
                              return null;
                            },
                            onSubmit: (value) {
                              cubit.searchProducts(value);
                            },
                            onChange: (value) {
                              cubit.searchProducts(value);
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: defaultcolor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              speech.isListening
                                  ? Icons.mic
                                  : Icons.mic_off_sharp,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              if (speechEnabled) {
                                if (speech.isListening) {
                                  stopListening();
                                } else {
                                  startListening(cubit);
                                }
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: defaultcolor,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.qr_code_scanner_sharp,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BarcodeScreen()));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  state is ShopSearchState || state is ShopProductsLoadedState
                      ? cubit.filteredProducts.isEmpty
                          ? Center(
                              child: Text(
                                'No Products Found',
                                style: GoogleFonts.montserrat(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            )
                          : FadeInUp(
                              duration: const Duration(milliseconds: 500),
                              child: ProductsListBuilder(
                                  cubit.filteredProducts, cubit))
                      : FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          child: ProductsListBuilder(
                              cubit.firebaseProducts, cubit))
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
