import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';
import 'package:taximate/models/app_data.dart';

class OfferInfo extends StatefulWidget {
  const OfferInfo({super.key});

  @override
  State<OfferInfo> createState() => _OfferInfoState();
}

class _OfferInfoState extends State<OfferInfo> {
  @override
  Widget build(BuildContext context) {
    var appData = context.watch<AppDataModel>();

    print("NIMONIMO ${appData.offerId}");

    return appData.offerId != ""
        ? StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('carpool_offers')
                .doc(appData.offerId)
                .snapshots(),
            builder: (context, snapshot) {
              print(
                  "HEY OFFERS ${snapshot.data != null ? snapshot.data?.data() : ''}");
              return Placeholder();
            })
        : Placeholder();
  }
}
