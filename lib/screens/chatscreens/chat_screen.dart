import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:skype/constants/strings.dart';
import 'package:skype/enum/view_state.dart';
import 'package:skype/models/message.dart';
import 'package:skype/models/user.dart';
import 'package:skype/provider/image_upload_provider.dart';
import 'package:skype/resources/auth_methods.dart';
import 'package:skype/resources/chat_methods.dart';
import 'package:skype/resources/storage_methods.dart';
import 'package:skype/screens/callscreens/pickup/pickup_layout.dart';
import 'package:skype/utils/call_utilities.dart';
import 'package:skype/utils/permissions.dart';
import 'package:skype/utils/universal_variables.dart';
import 'package:skype/utils/utils.dart';
import 'package:skype/widgets/appbar.dart';
import 'package:skype/widgets/cached_image.dart';
import 'package:skype/widgets/customfile.dart';

class ChatScreen extends StatefulWidget {
  final Userdetails receiver;
  const ChatScreen({Key? key, required this.receiver}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final StorageMethods _storageMethods = StorageMethods();
  final ChatMethods _chatMethods = ChatMethods();
  final AuthMethods _authMethods = AuthMethods();
  TextEditingController textFieldController = TextEditingController();
  final ScrollController _listScrollController = ScrollController();
  FocusNode textFieldFocus = FocusNode();
  late ImageUploadProvider _imageUploadProvider;

  bool isWriting = false;
  bool showEmojiPicker = false;
  late Userdetails sender;
  late String _currentUserId;

  void setWritingto(bool val) {
    setState(() {
      isWriting = val;
    });
  }

  showKeyboard() => textFieldFocus.requestFocus();
  hideKeyBoard() => textFieldFocus.unfocus();
  hideEmojiContainer() {
    setState(() {
      showEmojiPicker = false;
    });
  }

  showEmojiContainer() {
    setState(() {
      showEmojiPicker = true;
    });
  }

  @override
  void initState() {
    super.initState();
    User user = _authMethods.getCurrentUser()!;
    _currentUserId = user.uid;
    setState(() {
      sender = Userdetails(
        uid: user.uid,
        name: user.displayName,
        profilePhoto: user.photoURL,
        state: 0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    _imageUploadProvider = Provider.of<ImageUploadProvider>(context);
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: Colors.black,
        appBar: customAppBar(context),
        body: Column(
          children: [
            Flexible(child: messageList()),
            _imageUploadProvider.getViewState == ViewState.loading
                ? Container(
                    child: const CircularProgressIndicator(),
                    margin: const EdgeInsets.only(right: 15),
                    alignment: Alignment.centerRight,
                  )
                : Container(),
            chatControls(),
            showEmojiPicker
                ? SizedBox(
                    height: 250,
                    child: emojiContainer(),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  emojiContainer() {
    return EmojiPicker(
      onEmojiSelected: (category, emoji) {
        setState(() {
          isWriting = true;
        });
        textFieldController.text = textFieldController.text + emoji.emoji;
      },
      config: const Config(
        bgColor: UniversalVariables.separatorColor,
        indicatorColor: UniversalVariables.blueColor,
      ),
    );
  }

  Widget messageList() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(kMessages_Collection)
            .doc(_currentUserId)
            .collection(widget.receiver.uid!)
            .orderBy(kTimestamp_Field, descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: snapshot.data!.docs.length,
              reverse: true,
              controller: _listScrollController,
              itemBuilder: (context, index) {
                return chatMessageItem(snapshot.data!.docs[index]);
              });
        });
  }

  Widget chatMessageItem(DocumentSnapshot snapshot) {
    Map<String, dynamic> map = snapshot.data() as Map<String, dynamic>;
    Message _message = Message.fromMap(map);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      alignment: _message.senderId == _currentUserId
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: (_message.senderId == _currentUserId)
          ? senderLayout(_message)
          : receiverLayout(_message),
    );
  }

  Widget senderLayout(Message message) {
    Radius messageRadius = const Radius.circular(10);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        color: UniversalVariables.senderColor,
        borderRadius: BorderRadius.only(
          topLeft: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: getMessage(message),
      ),
    );
  }

  getMessage(Message message) {
    return message.type != kMessage_type_image
        ? Text(
            message.message!,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          )
        : CachedImage(
            imageurl: message.photoUrl!,
            height: 250,
            width: 250,
            radius: 10,
          );
  }

  Widget receiverLayout(Message message) {
    Radius messageRadius = const Radius.circular(10);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        color: UniversalVariables.receiverColor,
        borderRadius: BorderRadius.only(
          bottomRight: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: getMessage(message),
      ),
    );
  }

  addMediaModal(context) {
    showModalBottomSheet(
        context: context,
        elevation: 0,
        backgroundColor: Colors.black,
        builder: (context) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.maybePop(context),
                      child: const Icon(Icons.close),
                    ),
                    const Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Content and Tools',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                  child: ListView(
                children: [
                  ModalTile(
                    title: 'Media',
                    subtitle: 'Share photos and videos',
                    icon: Icons.image,
                    onTap: () => pickImage(ImageSource.gallery),
                  ),
                  ModalTile(
                    title: 'File',
                    subtitle: 'Share files',
                    icon: Icons.tab,
                    onTap: () {},
                  ),
                  ModalTile(
                    title: 'Contacts',
                    subtitle: 'Share Contacts',
                    icon: Icons.contacts,
                    onTap: () {},
                  ),
                  ModalTile(
                    title: 'Location',
                    subtitle: 'Share your Location',
                    icon: Icons.add_location,
                    onTap: () {},
                  ),
                  ModalTile(
                    title: 'Schedule Call',
                    subtitle: 'Arrange a skype call and get reminders',
                    icon: Icons.schedule,
                    onTap: () {},
                  ),
                  ModalTile(
                    title: 'Create Poll',
                    subtitle: 'Share Polls',
                    icon: Icons.poll,
                    onTap: () {},
                  ),
                ],
              ))
            ],
          );
        });
  }

  pickImage(ImageSource source) async {
    File selectedImage = await Utils.pickImage(source);
    _storageMethods.uploadImage(
        image: selectedImage,
        receiverId: widget.receiver.uid!,
        senderId: _currentUserId,
        imageUploadProvider: _imageUploadProvider);
  }

  Widget chatControls() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => addMediaModal(context),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                gradient: UniversalVariables.fabGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Stack(
              children: [
                TextField(
                  focusNode: textFieldFocus,
                  controller: textFieldController,
                  onTap: () => hideEmojiContainer(),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (val) {
                    (val.isNotEmpty && val.trim() != '')
                        ? setWritingto(true)
                        : setWritingto(false);
                  },
                  decoration: const InputDecoration(
                    hintText: 'Type a message',
                    hintStyle: TextStyle(
                      color: UniversalVariables.greyColor,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(50),
                        ),
                        borderSide: BorderSide.none),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    filled: true,
                    fillColor: UniversalVariables.separatorColor,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onPressed: () {
                      if (!showEmojiPicker) {
                        hideKeyBoard();
                        showEmojiContainer();
                      } else {
                        showKeyboard();
                        hideEmojiContainer();
                      }
                    },
                    icon: const Icon(Icons.face),
                  ),
                )
              ],
            ),
          ),
          isWriting
              ? Container()
              : const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.record_voice_over),
                ),
          isWriting
              ? Container()
              : GestureDetector(
                  child: const Icon(Icons.camera_alt),
                  onTap: () => pickImage(ImageSource.camera)),
          isWriting
              ? Container(
                  margin: const EdgeInsets.only(left: 10),
                  decoration: const BoxDecoration(
                    gradient: UniversalVariables.fabGradient,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                      onPressed: () => sendMessage(),
                      icon: const Icon(
                        Icons.send,
                        size: 15,
                      )),
                )
              : Container(),
        ],
      ),
    );
  }

  void sendMessage() {
    var text = textFieldController.text;
    Message _message = Message(
        senderId: sender.uid!,
        receiverId: widget.receiver.uid!,
        type: 'text',
        message: text,
        timestamp: Timestamp.now());
    setState(() {
      isWriting = false;
    });
    textFieldController.text = '';
    _chatMethods.addMessagetoDb(_message, sender, widget.receiver);
  }

  CustomAppBar customAppBar(context) {
    return CustomAppBar(
      title: Text(widget.receiver.name!),
      actions: [
        IconButton(
          onPressed: () async =>
              await Permissions.cameraAndMicrophonePermissionsGranted()
                  ? CallUtils.dial(
                      from: sender, to: widget.receiver, context: context)
                  : {},
          icon: const Icon(Icons.video_call),
        ),
        IconButton(
          onPressed: () async =>
              await Permissions.cameraAndMicrophonePermissionsGranted()
                  ? CallUtils.dial(
                      from: sender, to: widget.receiver, context: context)
                  : {},
          icon: const Icon(Icons.phone),
        ),
      ],
      leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back)),
      centerTitle: false,
    );
  }
}

class ModalTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final onTap;
  const ModalTile(
      {Key? key,
      required this.title,
      required this.subtitle,
      required this.icon,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: CustomTile(
        leading: Container(
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: UniversalVariables.receiverColor),
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            color: UniversalVariables.greyColor,
            size: 38,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        icon: Container(),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
              color: UniversalVariables.greyColor, fontSize: 14),
        ),
        trailing: Container(),
        onTap: onTap,
        onLongPress: () {},
        mini: false,
      ),
    );
  }
}
