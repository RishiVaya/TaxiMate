import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:taximate/firebase_firestore/firestore.dart';
import 'package:taximate/models/app_data.dart';
import 'package:taximate/components/bottom_navigation.dart';
import 'package:taximate/pages/offer_info.dart';
import 'package:taximate/pages/request_info.dart';

class CriteriaPage extends StatefulWidget {
  const CriteriaPage({super.key});

  @override
  State<CriteriaPage> createState() => _CriteriaPageState();
}

class _CriteriaPageState extends State<CriteriaPage> {
  List<String> listOfValueForGenders = ["Male", "Female", "Other"];
  String _selectedGender = '';
  String _selectedRating = '';
  List<Map<String, String>> listOfValueForRatings = [
    {"text": ">4.0", "value": "4.0"},
    {"text": ">3.0", "value": "3.0"},
    {"text": ">2.0", "value": "2.0"}
  ];

  @override
  Widget build(BuildContext context) {
    var appData = context.watch<AppDataModel>();

    void onRequest() async {
      // save to db
      var pickupAddress = appData.startAddressObj;
      var destAddress = appData.destinationAddressObj;

      var tripDataMap = {
        "pickup": [pickupAddress],
        "dropoff": [destAddress],
        "criteria": {
          "gender": _selectedGender,
          "desiredRating": _selectedRating
        }
      };

      var reqId = await Firestore().createCarpoolRequest(tripDataMap);

      if (reqId == null) {
        return;
      }

      // update app data
      appData.updateRequestId(reqId);

      // navigate to offer list page
      context.go('/request');
    }

    void onOffer() async {
      // save to db
      var pickupAddress = appData.startAddressObj;
      var destAddress = appData.destinationAddressObj;

      var tripDataMap = {
        "pickup": [pickupAddress],
        "dropoff": [destAddress],
        "criteria": {
          "gender": _selectedGender,
          "desiredRating": _selectedRating
        }
      };

      var reqId = await Firestore().createCarpoolOffer(tripDataMap);

      if (reqId == null) {
        return;
      }

      print(reqId);
      // update app data
      appData.updateOfferId(reqId);

      // navigate to offer list page
      context.go('/offer');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Optional Criteria'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 80.0),
                  DropdownButtonFormField(
                    value: _selectedGender.isNotEmpty ? _selectedGender : null,
                    hint: Text('Gender'),
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
                    onSaved: (value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
                    items: listOfValueForGenders.map((String val) {
                      return DropdownMenuItem(
                        value: val,
                        child: Text(
                          val,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 64.0),
                  DropdownButtonFormField(
                    value: _selectedRating.isNotEmpty ? _selectedRating : null,
                    hint: Text('Rating'),
                    onChanged: (value) {
                      setState(() {
                        _selectedRating = value!;
                      });
                    },
                    onSaved: (value) {
                      setState(() {
                        _selectedRating = value!;
                      });
                    },
                    items: listOfValueForRatings.map((Map<String, String> val) {
                      return DropdownMenuItem(
                        value: val["value"],
                        child: Text(
                          val["text"]!,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 64.0),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => onRequest(),
                        //
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'request carpool'.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      ElevatedButton(
                        onPressed: () => onOffer(),
                        //
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Offer carpool'.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const RequestInfo(),
                  const OfferInfo()
                ],
              ),
            ],
          )),
    );
  }
}
