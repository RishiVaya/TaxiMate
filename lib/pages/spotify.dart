import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:taximate/models/app_data.dart';
import '../auth/auth.dart';
import 'package:taximate/pages/secrets.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class SpotifyPage extends StatefulWidget {
  const SpotifyPage({super.key});

  @override
  State<SpotifyPage> createState() => _SpotifyPageState();
}

class _SpotifyPageState extends State<SpotifyPage> {
  final String accessToken = 'YOUR_ACCESS_TOKEN';
  final TextEditingController userIdController = TextEditingController();
  var userPlaylists = [];

  void queryPlaylistsByUserId() async {
// get access token
    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic ' +
            base64.encode(
                utf8.encode('${Secrets.CLIENTID}:${Secrets.CLIENT_SECRET}')),
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'client_credentials',
      },
    );

    var accessToken;

    if (response.statusCode == 200) {
      // Request successful, parse response body
      final decodedBody = json.decode(response.body);
      // Extract access token from the response
      accessToken = decodedBody['access_token'];
      // Use the accessToken to make further requests to the Spotify API
    } else {
      return;
      // Request failed, handle error
    }

    final responsePlay = await http.get(
      Uri.parse(
          'https://api.spotify.com/v1/users/${userIdController.text}/playlists'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    var playlists;

    if (responsePlay.statusCode == 200) {
      // Request successful, parse response body
      final decodedBody = json.decode(responsePlay.body);
      // Extract playlists from the response
      playlists = decodedBody['items'];
      // playlists variable will contain the list of playlists for the specified userId
      setState(() {
        userPlaylists = playlists;
      });
    } else {
      // Request failed, handle error
    }
  }

  void _showAlert(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Alert!!"),
          content: Text(error),
          actions: <Widget>[
            TextButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  int _currentIndex = 2;
  Map<int, String> pagesMap = {
    0: '/mapsac',
    1: '/profile',
    2: '/spotify',
  };

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    context.go('${pagesMap[index]}');
  }

  @override
  Widget build(BuildContext context) {
    var appData = context.watch<AppDataModel>();

    return Scaffold(
        appBar: AppBar(
          title: const Text('Send Playlist'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: userIdController,
                decoration: const InputDecoration(
                  labelText: 'UserId',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // const String clientId = Secrets.CLIENTID;
                  // const String redirectUri = Secrets.REDIRECT_URL;
                  // const String scope = 'user-read-email';
                  // //const String state = 'state';

                  // const String url =
                  //     "https://accounts.spotify.com/authorize?client_id=$clientId&response_type=code&redirect_uri=$redirectUri&scope=$scope";

                  // launchUrl(Uri.parse(url));
                  queryPlaylistsByUserId();
                },
                child: const Text('Get my Playlists'),
              ),
              if (userPlaylists.isNotEmpty)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListView.builder(
                      itemCount: userPlaylists.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xff764abc),
                              child: Icon(Icons.music_note),
                            ),
                            // title: Text(requests[index]['userInfo']['name']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10),
                                Text("${userPlaylists[index]['description']}"),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          _showAlert(context,
                                              "Playlist sent to stereo system!");
                                          // selectRequest(requests[index]
                                          //     ['tripData']['reqId']);
                                        },
                                        child: const Text('Send playlist'),
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
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            unselectedItemColor: Colors.black,
            selectedItemColor: Colors.blue,
            onTap: _onTabTapped,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              //BottomNavigationBarItem(
              //  icon: Icon(Icons.search),
              //  label: 'Search',
              //),

              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
              if (appData.offerId != '')
                BottomNavigationBarItem(
                  icon: Icon(Icons.music_note),
                  label: 'Music',
                )
            ]));
  }
}
