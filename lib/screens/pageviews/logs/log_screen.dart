import 'package:flutter/material.dart';
import 'package:skype/screens/callscreens/pickup/pickup_layout.dart';
import 'package:skype/screens/pageviews/widgets/floating_column.dart';
import 'package:skype/screens/pageviews/widgets/log_list_container.dart';

import 'package:skype/widgets/skype_appbar.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: Colors.black,
        appBar: SkypeAppBar(
          title: 'Calls',
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/search_screen');
                },
                icon: const Icon(
                  Icons.search,
                  color: Colors.white,
                )),
          ],
        ),
        floatingActionButton: const FloatingColumn(),
        body: const Padding(
          padding: EdgeInsets.only(left: 15),
          child: LogListContainer(),
        ),
      ),
    );
  }
}
