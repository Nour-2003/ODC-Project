import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Models/Product Model.dart';
import '../../Screens/Cart/Cart screen.dart';
import '../../Screens/Home/Home Page.dart';
import '../../Screens/Profile/Profile Screen.dart';
import '../../Screens/Search/Search Screen.dart';
import 'Shop States.dart';

class ShopCubit extends Cubit<ShopStates> {
  ShopCubit() : super(ShopInitialState());

  static ShopCubit get(context) => BlocProvider.of(context);
  List firebaseProducts = [];
  void initializeData() {
    getData();
    getCategories();
    getCartData();
    String? email = FirebaseAuth.instance.currentUser?.email;
    if (email != null) {
      getUserByEmail(email);
    }
  }
  void getData() async {
    emit(
        GetFirebaseDataLoadingState());
    try {
      firebaseProducts.clear();
      QuerySnapshot query =
          await FirebaseFirestore.instance.collection('Products').get();
      firebaseProducts.addAll(query.docs);
      emit(GetFirebaseDataState());
    } catch (error) {
      emit(GetFirebaseDataErrorState(error.toString()));
    }
  }

  Map<String, dynamic>? userData;

  void getUserByEmail(String email) {
    emit(UserLoading()); // Emit loading state
    try {
      CollectionReference users =
          FirebaseFirestore.instance.collection('Users');

      users.where('email', isEqualTo: email).get().then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
          emit(UserLoaded(userData!));
        } else {
          emit(UserError('No user found with email: $email'));
        }
      }).catchError((e) {
        emit(UserError('Error fetching user by email: $e'));
      });
    } catch (e) {
      emit(UserError('Unexpected error occurred: $e')); // Emit error state
    }
  }

  int currentIndex = 0;
  List<String> titles = [
    'Home',
    'Search',
    'Cart',
    'Profile',
  ];
  List<Widget> screens = [
    HomePage(),
    SearchScreen(),
    CartPage(),
    ProfileScreen(),
  ];
  List CartItems = [];

  void getCartData() {
    emit(GetCartData());
    FirebaseFirestore.instance
        .collection('Cart')
        .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .listen((snapshot) {
      CartItems = snapshot.docs;
      emit(GetCartDataSuccess());
    }, onError: (error) {
      print("Error getting cart data: $error");
      emit(GetCartDataError());
    });
  }

  Future<void> addToCart(String title, String price, String description,
      String category, String imageUrl, String rating, String count) async {
    try {
      // Get the current user's ID
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Query the Cart collection for the product with the same title and user ID
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Cart')
          .where('title', isEqualTo: title)
          .where('id', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Product already exists in the cart, update the quantity
        final docId = querySnapshot.docs.first.id; // Get the document ID
        final currentQuantity =
            querySnapshot.docs.first.data()['quantity'] as int;

        await FirebaseFirestore.instance.collection('Cart').doc(docId).update({
          'quantity': currentQuantity + 1,
        });

        emit(AddToCartSuccess());
      } else {
        // Product not found, add a new entry
        await FirebaseFirestore.instance.collection('Cart').add({
          'title': title,
          'price': price,
          'description': description,
          'category': category,
          'imageUrl': imageUrl,
          'rating': rating,
          'count': count,
          'id': userId,
          'quantity': 1,
        });

        emit(AddToCartSuccess());
      }
    } catch (error) {
      print("Failed to add/update item: $error");
      emit(AddToCartError());
    }
  }

  void changeBottomNav(int index) {
    currentIndex = index;
    emit(ShopChangeBottomNavState());
  }

  ProductModel productModel = ProductModel(
    products: [],
  );

  List products = [];
  List filteredProducts = [];

  void loadProducts(List newProducts) {
    products = newProducts;
    filteredProducts = List.from(products);
    emit(ShopProductsLoadedState());
  }

  void searchProducts(String searchTerm) {
    emit(ShopSearchLoadingState());

    if (searchTerm.isEmpty) {
      filteredProducts = firebaseProducts;
    } else {
      filteredProducts = products
          .where((product) =>
              product['title']
                  .toLowerCase()
                  .contains(searchTerm.toLowerCase()) ||
              product['category']
                  .toLowerCase()
                  .contains(searchTerm.toLowerCase()))
          .toList();
    }
    emit(ShopSearchState());
  }

  ProductModel categoryProductModel = ProductModel(
    products: [],
  );
  void toggleFavoriteStatus(String productId,context) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final favoritesRef = FirebaseFirestore.instance.collection('Users').doc(userId).collection('favorites');

    final favoriteDoc = await favoritesRef.doc(productId).get();
    if (favoriteDoc.exists) {
      await favoritesRef.doc(productId).delete().then((value) => AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        title: 'Success',
        desc: 'Product removed from favorites.',
        btnOkOnPress: () {},
      )..show(
      ));
    } else {
      await favoritesRef.doc(productId).set({'productId': productId}).then((value) => AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        title: 'Success',
        desc: 'Product added to favorites.',
        btnOkOnPress: () {},
      )..show(
      ));
    }

    emit(FavoriteStatusChangedState());
  }

  Object isFavorite(String productId) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return false;

    final favoriteDoc = FirebaseFirestore.instance.collection('Users').doc(userId).collection('favorites').doc(productId);
    return favoriteDoc.get().then((doc) => doc.exists);
  }
  Future<void> updateCategoryAndProducts(
      String title, String newName, String newImageUrl) async {
    emit(CategoriesLoading());
    try {
      // Query the category document by title
      final categorySnapshot = await FirebaseFirestore.instance
          .collection('Categories')
          .where('name', isEqualTo: title)
          .get();

      if (categorySnapshot.docs.isEmpty) {
        throw Exception('No category found with the title: $title');
      }

      // Assuming titles are unique, get the first matching category document
      final categoryDoc = categorySnapshot.docs.first;

      // Update the category
      await FirebaseFirestore.instance
          .collection('Categories')
          .doc(categoryDoc.id)
          .update({
        'name': newName.isNotEmpty ? newName : categoryDoc['name'],
        'imageUrl': newImageUrl.isNotEmpty ? newImageUrl : categoryDoc['imageUrl'],
      });

      // Query all products with the old category name
      final productsSnapshot = await FirebaseFirestore.instance
          .collection('Products')
          .where('category', isEqualTo: title)
          .get();

      if (productsSnapshot.docs.isNotEmpty) {
        // Create a batch to update all products
        final batch = FirebaseFirestore.instance.batch();

        for (final productDoc in productsSnapshot.docs) {
          final productRef = FirebaseFirestore.instance
              .collection('Products')
              .doc(productDoc.id);

          batch.update(productRef, {'category': newName});
        }

        // Commit the batch
        await batch.commit();
      }

      emit(CategoryUpdatedSuccessState());
    } catch (e) {
      print('Error updating category and products: $e');
      emit(CategoryUpdatedErrorState(e.toString()));
    }
  }


  List categoryProducts = [];
  List firebaseCategories = [];

  void getCategories() async {
    emit(ShopGetCategories());
    try {
      QuerySnapshot query =
          await FirebaseFirestore.instance.collection('Categories').get();
      firebaseCategories = query.docs;
      emit(ShopGetCategoriesSuccess());
    } catch (error) {
      emit(ShopGetCategoriesError());
    }
  }

  String selectedCategory = '';

  void selectCategory(String categoryName) {
    if (selectedCategory != categoryName) {
      selectedCategory = categoryName;
      getProductsFromCategory(categoryName);
    }
  }

  void editCategory(String title, String name, String imageUrl) async {
    if (title.isEmpty) {
      print("Title cannot be empty.");
      emit(ProductUpdatedErrorState("Title cannot be empty."));
      return;
    }

    try {
      // Query the collection to find the document by title
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Categories')
          .where('title', isEqualTo: title)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print("Category with the specified title not found.");
        emit(ProductUpdatedErrorState("Category with the specified title not found."));
        return;
      }

      // Assuming titles are unique, take the first matching document
      final doc = querySnapshot.docs.first;

      // Prepare update data
      Map<String, dynamic> updateData = {};
      if (name.isNotEmpty) {
        updateData['name'] = name;
      }
      if (imageUrl.isNotEmpty) {
        updateData['imageUrl'] = imageUrl;
      }

      if (updateData.isEmpty) {
        print("No valid fields to update.");
        emit(ProductUpdatedErrorState("No valid fields to update."));
        return;
      }

      // Update the document
      await FirebaseFirestore.instance
          .collection('Categories')
          .doc(doc.id)
          .update(updateData);

      emit(ProductsUpdatedState());
    } catch (error) {
      print("Error updating category: $error");
      emit(ProductUpdatedErrorState(error.toString()));
    }
  }


  void getProductsFromCategory(String categoryName) async {
    emit(ShopLoadingCatProductsDataState());
    try {
      categoryProducts.clear(); // Clear existing products first

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Products')
          .where('category', isEqualTo: categoryName)
          .get();

      // Filter products for the specified category
      querySnapshot.docs.forEach((doc) {
        if (doc['category'] == categoryName) {
          categoryProducts.add(doc);
        }
      });

      emit(ShopSuccessCatProductsDataState());
    } catch (error) {
      print('Error getting products for category $categoryName: $error');
      emit(ShopErrorCatProductsDataState());
    }
  }

  Future<void> updateProduct(String productId, String newTitle, String newPrice,
      String newDescription) async {
    try {
      // Update the main 'Products' collection
      await FirebaseFirestore.instance
          .collection('Products')
          .doc(productId)
          .update({
        'title': newTitle,
        'price': newPrice,
        'description': newDescription,
      });

      // Update local Data list
      int index =
          firebaseProducts.indexWhere((product) => product['id'] == productId);
      if (index != -1) {
        firebaseProducts[index]['title'] = newTitle;
        firebaseProducts[index]['price'] = newPrice;
        firebaseProducts[index]['description'] = newDescription;
        emit(ProductsUpdatedState()); // Trigger UI rebuild
      }
    } catch (error) {
      print("Error updating product: $error");
      emit(ProductUpdatedErrorState(error.toString()));
    }
  }
}
