import 'package:busan_univ_matzip/providers/user_provider.dart';
import 'package:busan_univ_matzip/screen/home_page_screen.dart';
import 'package:busan_univ_matzip/screen/setting_screen.dart';
import 'package:busan_univ_matzip/screen/post_builder_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _bottomNavIndex = 2;

  @override
  void initState() {
    super.initState();
    addData();
  }

  void addData() async {
    UserProvider userProvider = Provider.of(context, listen: false);
    await userProvider.refereshUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(children: [
          Offstage(
            key: UniqueKey(),
            offstage: _bottomNavIndex != 0,
            child: Center(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.food_bank_outlined,
                    size: 40,
                  ),
                ),
                const Text("오늘 머먹지"),
              ],
            )),
          ),
          Offstage(
            offstage: _bottomNavIndex != 1,
            child: const Text("second"),
          ),
          Offstage(
            offstage: _bottomNavIndex != 2,
            child: const PostScreen(),
          ),
          Offstage(
            offstage: _bottomNavIndex != 3,
            child: const PostBuilderPage(),
          ),
          Offstage(
            offstage: _bottomNavIndex != 4,
            child: const SettingScreen(),
          )
        ]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        showUnselectedLabels: false,
        onTap: (index) => setState(() => _bottomNavIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: "menu",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.safety_check),
            label: "hi",
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.pencil),
            label: "post",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.safety_check),
            label: "hi",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "설정",
          ),
        ],
      ),
    );
  }
}
