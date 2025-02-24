import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:odc_project/Screens/Login-SignUp/Login%20Screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
class OnBoardingScreen extends StatefulWidget {
  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  var boardController = PageController();
  bool islast = false;
  int currentPage = 0;List<OnBoardingModel> onBoarding = [
    OnBoardingModel(
      image: "Images/fashion shop-rafiki 1.png",
      title: 'Choose Products',
      body: 'Explore a wide range of high-quality products tailored to your needs. Find exactly what you’re looking for with ease and add it to your cart in just a few taps.',
    ),
    OnBoardingModel(
      image: "Images/Sales consulting-pana 1.png",
      title: 'Make Payment',
      body: 'Enjoy a seamless and secure checkout experience. Choose from multiple payment options and complete your purchase with confidence.',
    ),
    OnBoardingModel(
      image: "Images/Shopping bag-rafiki 1.png",
      title: 'Get Your Order',
      body: 'Sit back and relax while we prepare your order. Receive timely updates and track your delivery until it arrives at your doorstep.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        centerTitle: true,
        leadingWidth: 100,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: AnimatedBuilder(
            animation: boardController,
            builder: (context, child) {
              int currentPage = (boardController.hasClients && boardController.page != null)
                  ? (boardController.page!.round() + 1)
                  : 1;
              return Text(
                '$currentPage/${onBoarding.length}',
                style: GoogleFonts.montserrat(fontSize: 20,fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
              },
              child: Text(
                'Skip',
                style:GoogleFonts.montserrat(fontSize: 20,fontWeight: FontWeight.w600
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            children: [
              SizedBox(
                height: screenHeight * 0.8,
                child: PageView.builder(
                  onPageChanged: (index) {
                    setState(() {
                      islast = index == onBoarding.length - 1;
                    });
                  },
                  controller: boardController,
                  itemBuilder: (context, index) => OnBoardingItem(onBoarding[index], screenWidth, screenHeight),
                  itemCount: 3,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      if (boardController.hasClients && boardController.page! > 0) {
                        boardController.previousPage(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(
                      boardController.hasClients && boardController.page! > 0 ? "Prev" : "",
                      style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xffC4C4C4)),
                    ),
                  ),
                  SmoothPageIndicator(
                    controller: boardController,
                    count: onBoarding.length,
                    effect: const ExpandingDotsEffect(
                      dotColor: Colors.grey,
                      activeDotColor: Color(0xFF17223B),
                      dotHeight: 12,
                      expansionFactor: 3,
                      dotWidth: 14,
                      spacing: 10.0,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (islast) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                      } else {
                        if (boardController.hasClients) {
                          boardController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        }
                      }
                    },
                    child: Text(
                      islast ? "Get Started" : "Next",
                      style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xffF83758)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget OnBoardingItem(OnBoardingModel model, double screenWidth, double screenHeight) => Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(model.image, width: screenWidth * 0.8),
      ),
      SizedBox(height: screenHeight * 0.02),
      Text(
        model.title,
        style: GoogleFonts.montserrat(fontSize: screenWidth * 0.07, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: screenHeight * 0.01),
      Text(
        textAlign: TextAlign.center,
        model.body,
        style: GoogleFonts.montserrat(fontSize: screenWidth * 0.04),
      ),
    ],
  );
}

class OnBoardingModel {
  final String image;
  final String title;
  final String body;

  OnBoardingModel({required this.image, required this.title, required this.body});
}
