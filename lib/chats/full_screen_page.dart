import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:yandex_cup_reaction/models/message_model.dart';
import 'package:yandex_cup_reaction/widgets/toast_widget.dart';

class FullScreenPage extends StatefulWidget {
  final Function onCancel;
  final Function onAccept;
  final MessageModel messageModel;
  final String? chatRoomId;

  const FullScreenPage(
      {Key? key,
      required this.onCancel,
      required this.onAccept,
      required this.messageModel,
      required this.chatRoomId})
      : super(key: key);

  @override
  State<FullScreenPage> createState() => _FullScreenPageState();
}

class _FullScreenPageState extends State<FullScreenPage> {
  bool showSource = false;

  VideoPlayerController? _controller;
   CameraController? controller;

  @override
  void initState() {
    Permission.camera.request().then((status) async {
      if (status == PermissionStatus.granted) {
        await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Подверждение'),
            content: const Text(
                // 'Do you agree to record your reaction while watching image/video?'),
                'Вы согласны записывать свою реакцию во время просмотра изображения/видео?'),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  await Navigator.of(context).maybePop();
                  await Navigator.of(context).maybePop();

                  widget.onCancel();
                },
                child: const Text('Отменить'),
              ),
              TextButton(
                onPressed: () async {
                  if ((widget.messageModel.defaultMessage?.fileUrl ?? '').isNotEmpty &&
                      widget.messageModel.defaultMessage!.fileUrl!
                          .contains('VideoType1342420492424')) {
                    _controller = VideoPlayerController.network(
                        widget.messageModel.defaultMessage?.fileUrl ?? '')
                      ..initialize().then((_) {
                        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
                        setState(() {});
                      });
                  }

                  final _cameras = await availableCameras();
                  controller = CameraController(_cameras[1], ResolutionPreset.medium);
                  await controller!.initialize().then((_) {
                    if (!mounted) {
                      return;
                    }
                    setState(() {});
                  }).catchError((Object e) async {
                    if (e is CameraException) {
                      switch (e.code) {
                        case 'CameraAccessDenied':
                          await Navigator.of(context).maybePop();
                          await Navigator.of(context).maybePop();
                          break;
                        default:
                          print('Handle other errors.');
                          break;
                      }
                    }
                  });
                  await controller!.startVideoRecording();

                  await Navigator.of(context).maybePop();
                  setState(() {
                    showSource = true;
                  });
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {}
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: showSource &&
                (widget.messageModel.defaultMessage?.fileUrl ?? '').isNotEmpty &&
                widget.messageModel.defaultMessage!.fileUrl!.contains('VideoType1342420492424')
            ? FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                  });
                },
                child: Icon(
                  _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
              )
            : null,
        body: WillPopScope(
          onWillPop: () async {
            ToastWidget.showToast('Please wait.\nStopping video and sending to sender', toastLength: Toast.LENGTH_LONG);
            final xFile = await controller!.stopVideoRecording();

            final storageRef = FirebaseStorage.instance.ref();
            final mountainsRef = storageRef.child('VideoType1342420492424${xFile.name}' ?? '123');
            await mountainsRef.putFile(File(xFile.path ?? ''));
            final fileUrl = await mountainsRef.getDownloadURL();

            FirebaseFirestore.instance
                .collection('chat_rooms')
                .doc(widget.chatRoomId)
                .collection('messages')
                .doc()
                .set(MessageModel(
                        senderId: FirebaseAuth.instance.currentUser!.uid,
                        reaction: Reaction(
                            messageIdOfReaction: widget.messageModel.messageId, reactionUrl: fileUrl))
                    .toJson());

            // await Navigator.of(context).maybePop();

            return true;
          },
          child: SafeArea(
            child: !showSource
                ? const SizedBox.shrink()
                : Column(
                    children: [
                      if ((widget.messageModel.defaultMessage?.fileUrl ?? '').isNotEmpty &&
                          widget.messageModel.defaultMessage!.fileUrl!
                              .contains('ImageType1342420492424'))
                        Expanded(
                          // height: MediaQuery.of(context).size.height / 2,
                          child: CachedNetworkImage(
                            imageUrl: widget.messageModel.defaultMessage!.fileUrl!,
                            progressIndicatorBuilder: (context, url, downloadProgress) =>
                                CircularProgressIndicator(value: downloadProgress.progress),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                        ),
                      if ((widget.messageModel.defaultMessage?.fileUrl ?? '').isNotEmpty &&
                          widget.messageModel.defaultMessage!.fileUrl!
                              .contains('VideoType1342420492424'))
                        _controller!.value.isInitialized
                            ? AspectRatio(
                                aspectRatio: _controller!.value.aspectRatio,
                                child: VideoPlayer(_controller!),
                              )
                            : Container(),
                      // Expanded(child: CameraPreview(controller))
                    ],
                  ),
          ),
        ));
  }
}
