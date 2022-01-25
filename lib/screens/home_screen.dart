import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:skype/enum/user_state.dart';
import 'package:skype/provider/user_provider.dart';
import 'package:skype/resources/auth_methods.dart';
import 'package:skype/resources/local_db/repository/log_repostiory.dart';
import 'package:skype/screens/contactscreen/contact_screen.dart';
import 'package:skype/screens/pageviews/chat_list_screen.dart';
import 'package:skype/screens/pageviews/logs/log_screen.dart';
import 'package:skype/utils/universal_variables.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  UserProvider? userProvider;
  AuthMethods _authMethods = AuthMethods();
  late PageController pageController;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider!.refreshUser();

    WidgetsBinding.instance!.addObserver(this);

    pageController = PageController();

    SchedulerBinding.instance!.addPostFrameCallback((_) async {
      userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider!.refreshUser();
      _authMethods.setUserState(
          userId: userProvider!.getUser!.uid!, userState: UserState.online);
      LogRepository.init(isHive: false, dbName: userProvider!.getUser!.uid!);
    });
  }

  onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    String currentUserId =
        (userProvider != null && userProvider!.getUser != null)
            ? userProvider!.getUser!.uid!
            : '';
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        _authMethods.setUserState(
            userId: currentUserId, userState: UserState.online);
        break;
      case AppLifecycleState.inactive:
        _authMethods.setUserState(
            userId: currentUserId, userState: UserState.offline);
        break;
      case AppLifecycleState.paused:
        _authMethods.setUserState(
            userId: currentUserId, userState: UserState.waiting);
        break;
      case AppLifecycleState.detached:
        _authMethods.setUserState(
            userId: currentUserId, userState: UserState.offline);

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView(
        children: [
          const ChatListScreen(),
          const LogScreen(),
          ContactScreen(),
        ],
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: CupertinoTabBar(
          backgroundColor: Colors.black,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.chat,
              ),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.call,
              ),
              label: 'Calls',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.contact_phone,
              ),
              label: 'Contacts',
            ),
          ],
          currentIndex: _page,
          onTap: navigationTapped,
          activeColor: UniversalVariables.lightBlueColor,
          inactiveColor: UniversalVariables.greyColor,
        ),
      ),
    );
  }
}
