import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OfferPage extends StatefulWidget {
  @override
  State<OfferPage> createState() => _OfferPageState();
}

// void setTripLocation(String location) {}

// void setTripCriteria(String criteria) {}

// void setSelectedOffer() {}

class _OfferPageState extends State<OfferPage> {
  List<int> offers = [1, 2, 3];
  bool showOffers = false;
  int _currentIndex = 0;
  Map<int, String> pagesMap = {0: '/'};

  void _oncancel() {}

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
