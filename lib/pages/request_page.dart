import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:taximate/firebase_firestore/firestore.dart';
import '../models/app_data.dart';

class RequestPage extends StatefulWidget {
  @override
  State<RequestPage> createState() => _RequestPageState();
}

// void setTripLocation(String location) {}

// void setTripCriteria(String criteria) {}

// void setSelectedOffer() {}

class _RequestPageState extends State<RequestPage> {
  List offers = [];
  bool showOffers = false;
  int _currentIndex = 0;
  Map<int, String> pagesMap = {0: '/'};

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    context.go('${pagesMap[index]}');
  }

  @override
  Widget build(BuildContext context) {
    var appData = context.watch<AppDataModel>();

    void _retrieveOffers() async {
      var ans = await Firestore().getRelevantOffersByRequest(appData.requestId);
      offers = ans;
      print(offers);
    }

    void _findOffer() {
      _retrieveOffers();
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

    void _oncancel() async {
      await Firestore().updateCarpoolRequestStatus(appData.requestId, true);
      context.go('/');
    }

    void _onSelect() async {
      print(appData.requestId);
    }

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
              onPressed: () {
                _findOffer();
              },
              child: Text('FIND OFFERS'),
            ),
            if (showOffers)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListView.builder(
                    itemCount: offers.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xff764abc),
                            child: Text(offers[index]['userInfo']['name'][0]),
                          ),
                          title: Text(offers[index]['userInfo']['name']),
                          subtitle: Text('Item description'),
                          onTap: () {
                            print(offers[index]['userInfo']);
                            _onSelect();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            Expanded(
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red),
                      ),
                      onPressed: () {
                        _oncancel();
                        //context.go('/');
                      },
                      child: const Text('CANCEL TRIP'),
                    ))),
          ],
        ),
      ),
    );
  }
}
