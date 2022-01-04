import 'package:flutter/material.dart';
import 'package:uber_seller/authentication/auth_screen.dart';
import 'package:uber_seller/global/global.dart';
import 'package:uber_seller/uploadScreens/menu_upload_screen.dart';
import 'package:uber_seller/widgets/my_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        title: Text(
          sharedPreferences!.getString("name")!,
          style: const TextStyle(fontSize: 30, fontFamily: 'Lobster'),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (c) => const MenusUploadScreen()));
            },
            icon: const Icon(Icons.post_add, color: Colors.white),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.cyan,
                Colors.amber,
              ],
              begin: FractionalOffset(0.0, 0.0),
              end: FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers:[
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
            .collection('sellers')
            .doc(sharedPreferences.getString('uid'))
            .collection('menus').snapshots(),
            initialData: initialData,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return Container(
                child: child,
              );
            },
          ),
        ],
      ),
    );
  }
}
