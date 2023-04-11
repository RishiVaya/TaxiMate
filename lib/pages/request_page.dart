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

    Future<List> retrieveOffers() async {
      var ans = await Firestore().getRelevantOffersByRequest(appData.requestId);
      return ans;
    }

    void findOffer() async {
      var offerList = await retrieveOffers();
      print("${offerList}");
      if (offerList.isEmpty) {
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Sorry'),
              content: const Text(
                'There are Currently No Offers Available',
                textAlign: TextAlign.center,
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
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
          offers = offerList;
          showOffers = true;
        });
      }
    }

    void selectOffer(String offerId) async {
      var reqId = appData.requestId;
      await Firestore().selectOffer(offerId, reqId);
      context.go('/mapsr');
    }

    void _oncancel() async {
      await Firestore().updateCarpoolRequestStatus(appData.requestId, true);
      context.go('/');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Offers"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 25,
            ),
            Container(
              height: 50,
              child: ElevatedButton(
                onPressed: findOffer,
                child: const Text('FIND OFFERS'),
              ),
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
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              Text(
                                  "Pickup Location - ${offers[index]['tripData']['pickup'][0]['address']}"),
                              Text(
                                  "Rating - ${offers[index]['userInfo']['rating']}"),
                              Text("Fare - "),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        selectOffer(offers[index]['tripData']
                                            ['offerId']);
                                      },
                                      child: const Text('Select'),
                                    ),
                                  ]),
                            ],
                          ),
                          onTap: () {},
                        ),
                      );
                    },
                  ),
                ),
              ),
            Container(
              height: 50,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                  ),
                  onPressed: _oncancel,
                  child: const Text('CANCEL TRIP'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
