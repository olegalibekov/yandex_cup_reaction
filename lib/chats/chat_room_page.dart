import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:yandex_cup_reaction/chats/full_screen_page.dart';
import 'package:yandex_cup_reaction/models/message_model.dart';
import 'package:yandex_cup_reaction/widgets/bubble_special.dart' as widgets;
import 'package:yandex_cup_reaction/widgets/video_widget.dart';

class ChatRoomPage extends StatefulWidget {
  final String oppositeUserId;

  const ChatRoomPage({Key? key, required this.oppositeUserId}) : super(key: key);

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  get firstChatRoomId => '$currentUserId${widget.oppositeUserId}';

  get secondChatRoomId => '${widget.oppositeUserId}$currentUserId';

  String? currentChatRoomId;

  final listViewController = ItemScrollController();

  Future<bool> checkIfDocExists(String docId) async {
    try {
      final collectionRef = FirebaseFirestore.instance.collection('chat_rooms');
      final doc = await collectionRef.doc(docId).collection('messages').get();
      return doc.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> createChatIfAbsent(String chatId) async {
    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatId)
        .collection('messages')
        .doc()
        .set({});
  }

  Stream<QuerySnapshot> fetchChatRoom() async* {

    if (await checkIfDocExists(firstChatRoomId)) {
      currentChatRoomId = firstChatRoomId;
      yield* FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(firstChatRoomId)
          .collection('messages')
          .snapshots();
    } else if (await checkIfDocExists(secondChatRoomId)) {
      currentChatRoomId = secondChatRoomId;
      yield* FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(secondChatRoomId)
          .collection('messages')
          .snapshots();
    } else {
      await createChatIfAbsent(firstChatRoomId);
      currentChatRoomId = firstChatRoomId;
      yield* FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(firstChatRoomId)
          .collection('messages')
          .snapshots();
    }
  }

  final ImagePicker _picker = ImagePicker();

  Future<XFile?> _onImageButtonPressed() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    return pickedFile;
  }

  Future<XFile?> _onVideoButtonPressed() async {
    final XFile? pickedFile = await _picker.pickVideo(
      source: ImageSource.gallery,
    );
    return pickedFile;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Column(
        children: [
          StreamBuilder(
            stream: fetchChatRoom(),
            builder: (BuildContext context, snapshot) {
              if (snapshot.hasData && !snapshot.hasError) {
                final messages = (snapshot.data?.docs.map((e) {
                          return MessageModel.fromJson((e).data() as Map<String, dynamic>)
                            ..messageId = e.id;
                        }) ??
                        [])
                    .toList()
                  ..sort((MessageModel a, MessageModel b) =>
                      (a.timestamp ?? 0).compareTo((b.timestamp ?? 0)));



                return Expanded(
                  child: ScrollablePositionedList.builder(
                    itemScrollController: listViewController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          if (messages[index].defaultMessage != null)
                            widgets.BubbleSpecialOne(
                              text: messages[index].defaultMessage?.text ?? '',
                              isSender: (messages[index].senderId ?? '') == (currentUserId ?? ''),
                              color: Colors.cyan,
                              tail: true,
                              textStyle: const TextStyle(color: Colors.white, fontSize: 16),
                              actions: [
                                Text(
                                  'message ID = ${messages[index].messageId}' ?? '',
                                  style: const TextStyle(color: Colors.black, fontSize: 12),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                if ((messages[index].senderId ?? '') == (currentUserId ?? '') &&
                                    messages[index].defaultMessage!.fileUrl != null &&
                                    messages[index]
                                        .defaultMessage!
                                        .fileUrl!
                                        .contains('ImageType1342420492424'))
                                  CachedNetworkImage(
                                    imageUrl: messages[index].defaultMessage!.fileUrl!,
                                    progressIndicatorBuilder: (context, url, downloadProgress) =>
                                        CircularProgressIndicator(value: downloadProgress.progress),
                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                  ),
                                if ((messages[index].senderId ?? '') == (currentUserId ?? '') &&
                                    messages[index].defaultMessage!.fileUrl != null &&
                                    messages[index]
                                        .defaultMessage!
                                        .fileUrl!
                                        .contains('VideoType1342420492424'))
                                  VideoWidget(
                                      videoLink: messages[index].defaultMessage!.fileUrl ?? ''),
                                if ((messages[index].senderId ?? '') != (currentUserId ?? ''))
                                  if ((messages[index].defaultMessage?.fileUrl ?? '').isNotEmpty)
                                    InkWell(
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => FullScreenPage(
                                                    onCancel: () {
                                                      FirebaseFirestore.instance
                                                          .collection('chat_rooms')
                                                          .doc(currentChatRoomId)
                                                          .collection('messages')
                                                          .doc()
                                                          .set(MessageModel(
                                                                  senderId: FirebaseAuth
                                                                      .instance.currentUser!.uid,
                                                                  reaction: Reaction(
                                                                      messageIdOfReaction:
                                                                          messages[index]
                                                                              .messageId))
                                                              .toJson());
                                                    },
                                                    onAccept: () {},
                                                    messageModel: messages[index],
                                                    chatRoomId: currentChatRoomId,
                                                  )),
                                        );
                                      },
                                      child: Stack(
                                        children: [
                                          Shimmer.fromColors(
                                              baseColor: Colors.grey.shade300,
                                              highlightColor: Colors.grey.shade100,
                                              child: Container(
                                                width: 200,
                                                height: 200,
                                                color: Colors.white,
                                              )),
                                          const Positioned.fill(
                                              child: Center(
                                                  child: Text(
                                            'Tap to see',
                                            style: TextStyle(color: Colors.cyan, fontSize: 18),
                                          )))
                                        ],
                                      ),
                                    ),
                              ],
                            ),
                          if (messages[index].reaction != null)
                            widgets.BubbleSpecialOne(
                              text: '',
                              isSender: (messages[index].senderId ?? '') == (currentUserId ?? ''),
                              color: Colors.cyan,
                              tail: true,
                              textStyle: const TextStyle(color: Colors.white, fontSize: 16),
                              actions: [
                                Column(
                                  children: [
                                    if ((messages[index].reaction?.messageIdOfReaction ?? '')
                                        .isNotEmpty)
                                      InkWell(
                                        onTap: () {
                                          listViewController.scrollTo(
                                            index: messages.indexWhere((element) =>
                                                element.messageId ==
                                                messages[index].reaction?.messageIdOfReaction),
                                            duration: const Duration(seconds: 1),
                                            curve: Curves.fastOutSlowIn,
                                          );
                                        },
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                'Реакция на сообщение с ID = ${messages[index].reaction?.messageIdOfReaction} (нажмите на текущее сообщение, чтобы посмотреть сообщение-источник)'),
                                            const SizedBox(
                                              height: 12,
                                            ),
                                            if (messages[index].reaction?.reactionUrl == null)
                                              const Text(
                                                'Статус: отказано в доступе к камере',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            if (messages[index].reaction?.reactionUrl != null &&
                                                messages[index].reaction!.reactionUrl!.isNotEmpty)
                                              VideoWidget(
                                                videoLink:
                                                    messages[index].reaction?.reactionUrl ?? '',
                                              )
                                          ],
                                        ),
                                      )
                                  ],
                                )
                              ],
                            ),
                        ],
                      );
                    },
                  ),
                );
              }

              return Container();
            },
          ),
          MessageBar(
            onSend: (text) => FirebaseFirestore.instance
                .collection('chat_rooms')
                .doc(currentChatRoomId)
                .collection('messages')
                .doc()
                .set(MessageModel(
                        senderId: FirebaseAuth.instance.currentUser!.uid,
                        defaultMessage: DefaultMessage(text: text))
                    .toJson()),
            actions: [
              InkWell(
                child: const Icon(
                  Icons.photo,
                  color: Colors.black,
                  size: 24,
                ),
                onTap: () async {
                  final xFile = await _onImageButtonPressed();

                  final storageRef = FirebaseStorage.instance.ref();
                  final mountainsRef =
                      storageRef.child('ImageType1342420492424${xFile?.name}' ?? '123');
                  await mountainsRef.putFile(File('${xFile?.path}' ?? ''));
                  final fileUrl = await mountainsRef.getDownloadURL();

                  FirebaseFirestore.instance
                      .collection('chat_rooms')
                      .doc(currentChatRoomId)
                      .collection('messages')
                      .doc()
                      .set(MessageModel(
                              senderId: FirebaseAuth.instance.currentUser!.uid,
                              defaultMessage: DefaultMessage(fileUrl: fileUrl))
                          .toJson());
                },
              ),
              const SizedBox(
                width: 16.0,
              ),
              InkWell(
                child: const Icon(
                  Icons.video_camera_back_outlined,
                  color: Colors.black,
                  size: 24,
                ),
                onTap: () async {
                  final xFile = await _onVideoButtonPressed();

                  final storageRef = FirebaseStorage.instance.ref();
                  final mountainsRef =
                      storageRef.child('VideoType1342420492424${xFile?.name}' ?? '123');
                  await mountainsRef.putFile(File(xFile?.path ?? ''));
                  final fileUrl = await mountainsRef.getDownloadURL();

                  FirebaseFirestore.instance
                      .collection('chat_rooms')
                      .doc(currentChatRoomId)
                      .collection('messages')
                      .doc()
                      .set(MessageModel(
                              senderId: FirebaseAuth.instance.currentUser!.uid,
                              defaultMessage: DefaultMessage(fileUrl: fileUrl))
                          .toJson());
                },
              ),
              const SizedBox(
                width: 8.0,
              )
              // Padding(
              //   padding: EdgeInsets.only(left: 8, right: 8),
              //   child: InkWell(
              //     child: Icon(
              //       Icons.camera_alt,
              //       color: Colors.green,
              //       size: 24,
              //     ),
              //     onTap: () {},
              //   ),
              // ),
            ],
          ),
        ],
      )),
    );
  }
}
