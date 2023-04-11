import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:taximate/firebase_firestore/firestore.dart';
import 'package:taximate/pages/offer_info.dart';
import '../models/app_data.dart';

class OfferPage extends StatefulWidget {
  @override
  State<OfferPage> createState() => _OfferPageState();
}

class _OfferPageState extends State<OfferPage> {
  List requests = [];
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
    var submitting = false;

    void selectRequest(String requestId) async {
      setState(() {
        submitting = true;
      });
      var offerId = appData.offerId;
      await Firestore().selectRequest(offerId, requestId);
      context.go('/mapsac');
    }

    void _oncancel() async {
      // await Firestore().updateCarpoolOfferStatusoffer(appData.offerId, true);
      context.go('/');
    }

    Future<void> retrieveRequests() async {
      if (!submitting) {
        var ans = await Firestore().getRequestsForOffer(appData.offerId);
        if (ans.isEmpty || submitting == true) {
          showOffers = false;
        } else {
          setState(() {
            requests = ans;
            showOffers = true;
          });
        }
      }
    }

    var stream = FirebaseFirestore.instance
        .collection('carpool_offers')
        .doc(appData.offerId)
        .snapshots();

    stream.listen((snapshot) async => {await retrieveRequests()});

    return Scaffold(
        appBar: AppBar(
          title: const Text("Requests"),
          centerTitle: true,
        ),
        body:
            // StreamBuilder<DocumentSnapshot>(
            //     stream: FirebaseFirestore.instance
            //         .collection('carpool_offers')
            //         .doc(appData.offerId)
            //         .snapshots(),
            //     builder: (context, snapshot) {
            //       if (snapshot.hasError) {
            //         return Placeholder();
            //       }

            //       return
            Center(
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 25,
              ),
              Container(
                height: 50,
                child: ElevatedButton(
                  onPressed: () => {},
                  child: const Text('FIND OFFERS'),
                ),
              ),
              if (showOffers)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListView.builder(
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xff764abc),
                              child: Text('sd'),
                            ),
                            // title: Text(requests[index]['userInfo']['name']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10),
                                Text(
                                    "Pickup Location - ${requests[index]['tripData']['pickup'][0]['address']}"),
                                Text(
                                    "Dropoff Location - ${requests[index]['tripData']['dropoff'][0]['address']}"),
                                Text(
                                    "Rating - ${requests[index]['userInfo']['rating']}"),
                                Text("Fare - "),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          selectRequest(requests[index]
                                              ['tripData']['reqId']);
                                        },
                                        child: const Text('Accept'),
                                      ),
                                    ]),
                              ],
                            ),
                            onTap: () {
                              //selectRequest(
                              //    requests[index]['tripData']['reqId']);
                            },
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
              const OfferInfo()
            ],
          ),
        )
        // }),
        );
  }
}
