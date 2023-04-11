import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';
import 'package:taximate/models/app_data.dart';

class RequestInfo extends StatefulWidget {
  const RequestInfo({super.key});

  @override
  State<RequestInfo> createState() => _RequestInfoState();
}

class _RequestInfoState extends State<RequestInfo> {
  @override
  Widget build(BuildContext context) {
    var appData = context.watch<AppDataModel>();

    print("NIMONIMO ${appData.requestId}");

    return appData.requestId != ""
        ? StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('carpool_requests')
                .doc(appData.requestId)
                .snapshots(),
            builder: (context, snapshot) {
              // print("HEY ${snapshot.data!.data()}");
              return Placeholder();
            })
        : Placeholder();
  }
}
