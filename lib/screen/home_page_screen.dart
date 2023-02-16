import 'package:busan_univ_matzip/managers/image_manager.dart';
import 'package:busan_univ_matzip/providers/user_provider.dart';
import 'package:busan_univ_matzip/widgets/custom_indicator.dart';
import 'package:busan_univ_matzip/widgets/post/appBar/app_bar_page_view_index_widget.dart';
import 'package:busan_univ_matzip/widgets/post/post_screen_sliver_header.dart';
import 'package:busan_univ_matzip/widgets/post/small_post_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final PageController _topPageController =
      PageController(initialPage: 0, viewportFraction: 1.25);
  final PageController _secondPageController = PageController(initialPage: 0);

  late final AnimationController _animationController =
      AnimationController(vsync: this, duration: _animationDuration);

  late final Animation<double> _opacityAnimation;
  late final Animation<double> _bottomTabOpacityAnimation;
  late final Animation<double> _sizeAnimation;

  final Duration _animationDuration = const Duration(milliseconds: 300);

  int _currentPage = 0;
  double _titleWidthFactor = 0.7;
  bool showSliverAppBarListTile = true;
  int _postCount = 5;

  void _playSanJiNi() {
    bool isScreenFullOfAppBar = _scrollController.offset <= 100;

    if (isScreenFullOfAppBar && !showSliverAppBarListTile) {
      _animationController.reverse();
      setState(() {
        showSliverAppBarListTile = true;
      });
    } else if (!isScreenFullOfAppBar && showSliverAppBarListTile) {
      _animationController.forward();
      setState(() {
        showSliverAppBarListTile = false;
      });
    }
  }

  void addData() async {
    UserProvider userProvider = Provider.of(context, listen: false);
    await userProvider.refereshUser();
  }

  @override
  void initState() {
    super.initState();
    addData();

    _opacityAnimation = Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(_animationController);

    _bottomTabOpacityAnimation = Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(_animationController);

    _sizeAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    _scrollController.addListener(() {
      _playSanJiNi();
    });
  }

  @override
  void dispose() {
    _topPageController.dispose();
    _secondPageController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  void _toggleSubtitleLength() {
    setState(() {
      if (_titleWidthFactor == 0.7) {
        _titleWidthFactor = 1;
      } else {
        _titleWidthFactor = 0.7;
      }
    });
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _addPost(BuildContext context) {
    Navigator.pushNamed(context, '/homePage/addPost');
  }

  @override
  Widget build(BuildContext context) {
    ImageManager imageManager = ImageManager();
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              collapsedHeight: kToolbarHeight,
              expandedHeight: size.height * 0.77,
              // pinned: true,

              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                expandedTitleScale: 1.2,
                title: FadeTransition(
                  opacity: _opacityAnimation,
                  child: Transform.translate(
                    offset: const Offset(0, -60),
                    child: AppBarPageViewIndexWidget(
                      currentPage: _currentPage,
                      pageViewItemCount: 5,
                    ),
                  ),
                ),
                background: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("posts")
                      .orderBy("timeStamp")
                      .snapshots(),
                  builder: (_, snapshot) {
                    if (snapshot.hasData) {
                      return PageView.builder(
                        controller: _topPageController,
                        onPageChanged: _onPageChanged,
                        clipBehavior: Clip.none,
                        itemCount: 4,
                        itemBuilder: (_, index) {
                          var doc = snapshot.data!.docs[index].data();
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Image.network(
                              doc['postURL'].toString(),
                              fit: BoxFit.cover,
                              frameBuilder: (context, child, frame,
                                      wasSynchronouslyLoaded) =>
                                  child,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                } else {
                                  return const CustomIndicator(offstage: false);
                                }
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  const Text("no Image to show"),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Text("no DAta");
                    }
                  },
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(21),
                child: FadeTransition(
                  opacity: _opacityAnimation,
                  child: ListTile(
                    textColor: Colors.white,
                    title: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _titleWidthFactor,
                        child: Text(
                          imageManager.imgTitles[_currentPage]["title"]!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    subtitle: GestureDetector(
                      onTap: _toggleSubtitleLength,
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _titleWidthFactor,
                        child: Text(
                          imageManager.imgTitles[_currentPage]["subtitle"]!,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    trailing: Stack(
                      alignment: Alignment.centerRight,
                      clipBehavior: Clip.none,
                      children: [
                        const Positioned(
                          bottom: 35,
                          child: FaIcon(
                            FontAwesomeIcons.plus,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        FaIcon(
                          imageManager.imgFaces[_currentPage],
                          color: Colors.white,
                          size: 25,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            /// sticky header
            ///
            // SliverStickyHeader.builder(
            //   builder: (context, state) => Container(
            //     height: 60.0,
            //     color: (state.isPinned ? Colors.pink : Colors.lightBlue)
            //         .withOpacity(1.0 - state.scrollPercentage),
            //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //     alignment: Alignment.centerLeft,
            //     child: const Text(
            //       'Header #1',
            //       style: TextStyle(color: Colors.white),
            //     ),
            //   ),
            //   sliver: SliverList(
            //     delegate: SliverChildBuilderDelegate(
            //       (context, i) => ListTile(
            //         leading: const CircleAvatar(
            //           child: Text('0'),
            //         ),
            //         title: Text('List tile #$i'),
            //       ),
            //       childCount: 4,
            //     ),
            //   ),
            // ),

            SliverPersistentHeader(
              pinned: true,
              delegate: CustomDelegate(),
            ),

            SliverGrid.builder(
              itemCount: _postCount,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 9 / 13,
              ),
              itemBuilder: (context, index) => StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("posts")
                    .orderBy("timeStamp")
                    .snapshots(),
                builder: (_, snapshot) {
                  if (snapshot.hasData) {
                    _postCount = snapshot.data!.docs.length;
                    var docs = snapshot.data!.docs[index].data();
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: SmallPostWidget(docs: docs),
                    );
                  } else {
                    return const Text("noData");
                  }
                },
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 300),
            ),
          ],
        ),
      ),
      // floatingActionButton: AddPostButton(
      //   onPressed: () => _addPost(context),
      //   offstage: !showSliverAppBarListTile,
      // ),

      /// animation FloatingBottomBar
      // floatingActionButton: BottomFloatingTabBar(bottomAppear: _bottomAppear),
    );
  }
}
