import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/app_data.dart';

class RequestPage extends StatefulWidget {
  @override
  State<RequestPage> createState() => _RequestPageState();
}

// void setTripLocation(String location) {}

// void setTripCriteria(String criteria) {}

// void setSelectedOffer() {}

class _RequestPageState extends State<RequestPage> {
  List<int> offers = [1, 2, 3];
  bool showOffers = false;
  int _currentIndex = 0;
  Map<int, String> pagesMap = {0: '/'};

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    context.go('${pagesMap[index]}');
  }

  void _findOffer() {
    if (offers.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Sorry'),
            content: Text(
              'There are Currently No Offers Available',
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        showOffers = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var appData = context.watch<AppDataModel>();
    void _oncancel() {}

    return Scaffold(
      appBar: AppBar(
        title: Text("Offers"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 25,
            ),
            ElevatedButton(
              onPressed: _findOffer,
              child: Text('Find offer'),
            ),
            if (showOffers)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: offers.length,
                    itemBuilder: (context, index) {
                      return Text('${offers[index]}');
                    },
                  ),
                ),
              ),
            Expanded(
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      onPressed: () {
                        context.go('/profile');
                      },
                      child: const Text('CANCEL TRIP'),
                    ))),
          ],
        ),
      ),
    );
  }
}
