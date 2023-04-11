import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:taximate/firebase_firestore/firestore.dart';
import 'package:taximate/pages/offer_info.dart';
import '../auth/auth.dart';
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
      if (!mounted) return;
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

    var stream = FirebaseFirestore.instance
        .collection('carpool_offers')
        .doc(appData.offerId)
        .snapshots();

    stream.listen((snapshot) async => {
          if (mounted) {await retrieveRequests()}
        });

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
                                Text(
                                    "Fare - \$${requests[index]['tripData']['distance'] * 0.7} "),
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

Future<List<Buddy>> makeBuddyList(BuildContext context) async {
  var appData = context.watch<AppDataModel>();
  List requests = await Firestore().getRequestsForOffer(appData.offerId);
  var currUser = await Auth().currentUser();
  List<Buddy> buddies = [];
  for (var request in requests) {
    if (request["userInfo"]["userId"] != currUser?.uid) {
      buddies.add(Buddy(request["userInfo"]["name"],0,request["userInfo"]["userId"]));
    }
  }
  var offer = await Firestore().getOffer(appData.offerId);
  var offerUserId = offer?["userId"];
  if (offerUserId != currUser?.uid) {
    var user = await Firestore().getUser(offerUserId);
    buddies.add(Buddy(user?["name"],0,offerUserId));
  }
  return buddies;
}

class RateBuddies extends StatefulWidget {
  @override
  State<RateBuddies> createState() => _RateBuddies();
}
class Buddy {
  final String name, userId;
  int rating;

  Buddy(this.name, this.rating, this.userId);
}

class _RateBuddies extends State<RateBuddies> {
  final List<int> _stars = [1, 2, 3, 4, 5];

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<List<Buddy>>(
      future: makeBuddyList(context),
      builder: (context, AsyncSnapshot<List<Buddy>> buddies) {
        if (buddies.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Rate Buddies'),
              centerTitle: true,
            ),
            body: ListView.builder(
              itemCount: buddies.data?.length,
              itemBuilder: (context, index) {
                final buddy = buddies.data?[index];
                return Card(
                  child: ListTile(
                    title: Text(buddy?.name??""),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _stars.map((star) {
                        return IconButton(
                          onPressed: () {
                            setState(() {
                              buddy?.rating = star;
                            });
                          },
                          icon: Icon(
                            buddy != null ? (star <= buddy.rating ? Icons.star : Icons.star_border): Icons.star,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                for (Buddy buddy in buddies.data?.toList() ?? []) {
                  Firestore().addPassengerRating(buddy.rating as Int, buddy.userId);
                }
                final List<int> ratings =
                  buddies.data?.map((buddy) => buddy.rating).toList() ?? [];
                print('Buddies ratings: $ratings');
                context.go('/');
              },
              child: const Icon(Icons.check),
            ),
          );
        } else { return Text("${buddies.error}"); }
      }
    );
  }
}