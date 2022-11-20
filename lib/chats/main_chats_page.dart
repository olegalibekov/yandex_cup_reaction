import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:yandex_cup_reaction/chats/chat_room_page.dart';
import 'package:yandex_cup_reaction/login/login_page.dart';
import 'package:yandex_cup_reaction/models/user_model.dart';
import 'package:yandex_cup_reaction/widgets/toast_widget.dart';

class MainChatsPage extends StatefulWidget {
  const MainChatsPage({Key? key}) : super(key: key);

  @override
  State<MainChatsPage> createState() => _MainChatsPageState();
}

class _MainChatsPageState extends State<MainChatsPage> {
  Stream<QuerySnapshot> fetchUsers() async* {
    yield* FirebaseFirestore.instance.collection('users').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Choose user to chat with',
            style: Theme.of(context).textTheme.headline5,
          ),
          StreamBuilder(
              stream: fetchUsers(),
              builder: (context, snapshot) {
                if (snapshot.hasData && !snapshot.hasError) {
                  final users = snapshot.data?.docs
                          .map((e) => UserModel.fromJson(e.data() as Map<String, dynamic>))
                          .toList()
                          .where((element) => element.id != FirebaseAuth.instance.currentUser?.uid)
                          .toList() ??
                      [];
                  return Expanded(
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ChatRoomPage(oppositeUserId: users[index].id ?? '')),
                            );
                          },
                          child: ListTile(
                            title: Text(users[index].name ?? 'Name not specified'),
                            subtitle: Text(users[index].email ?? 'Email not specified'),
                            leading: CachedNetworkImage(
                              imageUrl: users[index].photoUrl ?? '',
                              imageBuilder: (context, imageProvider) =>
                                  CircleAvatar(backgroundImage: imageProvider),
                              progressIndicatorBuilder: (context, url, downloadProgress) =>
                                  CircularProgressIndicator(value: downloadProgress.progress),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }

                return Container();
              }),
          ElevatedButton(
              onPressed: () async {
                ToastWidget.showToast('Please wait.\nSigning out');
                await FirebaseAuth.instance.signOut();

                setState(() {});
                await Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: const Text('Sign Out'))
        ],
      ),
    ));
  }
}
