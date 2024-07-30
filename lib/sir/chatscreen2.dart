import 'dart:convert';
import 'dart:io';
//import 'package:swipe_to/swipe_to.dart';
//import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';



class ChatPage extends StatefulWidget {

  final String fromId;
  final String toId;
  final String receiverName;

  const ChatPage({super.key, required this.fromId,required this.toId,required this.receiverName});


  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Map<String, GlobalKey> messageKeys = {};
  types.Message? _selectedMessage;
  List<types.Message> _messages = [];
  late types.User _user;
//  late Future<String> _receiverName;

  @override
  void initState() {
    super.initState();
    _user = types.User(id: widget.fromId);
   // _receiverName = _fetchReceiverName();
    _loadMessages();

  }

  void _addMessage(types.Message message) {
    final key = GlobalKey();
    messageKeys[message.id] = key;
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Photo'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleFileSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('File'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final message = types.FileMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        mimeType: lookupMimeType(result.files.single.path!),
        name: result.files.single.name,
        size: result.files.single.size,
        uri: result.files.single.path!,
      );

      _addMessage(message);
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final message = types.ImageMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: const Uuid().v4(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );

      _addMessage(message);
    }
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final index =
          _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
          (_messages[index] as types.FileMessage).copyWith(
            isLoading: true,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index =
          _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
          (_messages[index] as types.FileMessage).copyWith(
            isLoading: null,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });
        }
      }

      await OpenFilex.open(localPath);
    }
  }
  Future<Map<String, dynamic>> _fetchReceiverInfo() async {
    final apiUrl = 'http://localhost:8081/message'; // Adjust the URL to your API endpoint

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'myid': widget.fromId,
          'otherid': widget.toId,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> messages = jsonDecode(response.body)['messages'];
        String receiverName = 'Receiver Name';

        if (messages.isNotEmpty) {
          final Map<String, dynamic> lastMessage = messages.last;
          print(lastMessage);
          receiverName = lastMessage['from']['name'] ?? 'Receiver Name';
        } else {
          print('No messages found for the user.');
        }

        return {'receiverName': receiverName, 'messages': messages};
      } else {
        print('Failed to fetch receiver info. Status code: ${response.statusCode}');
        return {'receiverName': 'Receiver Name', 'messages': []};
      }
    } catch (e) {
      print('Error fetching receiver info: $e');
      return {'receiverName': 'Receiver Name', 'messages': []};
    }
  }


  void _handlePreviewDataFetched(
      types.TextMessage message,
      types.PreviewData previewData,
      ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  void _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(textMessage); // Add the message locally to update the UI

    try {
      // Make a POST request to the API endpoint
      final apiUrl = 'http://208.109.34.247:8025/messages';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'from': widget.fromId,
          'to': widget.toId,
          'message': message.text,
        }),
      );
      print(apiUrl);
      print( jsonEncode({
        'from': widget.fromId,
        'to': widget.toId,
        'message': message.text,
      }),);

      if (response.statusCode == 200) {
        print('Message sent successfully!');
        // Handle any additional logic if needed
      } else {
        print('Failed to send message. Status code: ${response.statusCode}');
        // Handle the error as needed
      }
    } catch (e) {
      print('Error sending message: $e');
      // Handle the error as needed
    }
  }
  void _loadMessages() async {
  //  EasyLoading.show();

    final apiUrl = 'http://208.109.34.247:8025/message';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'myid': widget.fromId,
        'otherid': widget.toId,
      }),
    );

    print(apiUrl);
    print(jsonEncode({
      'myid': widget.fromId,
      'otherid': widget.toId,
    }));

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData.containsKey('messages')) {


          final List<dynamic> messagesData = responseData['messages'];
         print(messagesData);

          final messages = messagesData.map<types.Message>((message) {
          //  print(message);
            final text = message['message'] as String? ?? '';
            final author = types.User(id: message['from']['_id'].toString());
           // final name = message['name'] as String? ?? "";

            // Determine the type of message and create the appropriate instance
            if (message.containsKey('yourTypeField') && message['yourTypeField'] == 'file') {
              return types.FileMessage(
                author: author,
                createdAt: message['sendAt'] != null
                    ? DateTime.fromMillisecondsSinceEpoch(int.parse(message['sendAt']), isUtc: true).millisecondsSinceEpoch
                    : DateTime.now().millisecondsSinceEpoch,


                id: message['_id'].toString(),
                name: message['name'],
                size: message['size'] ?? 0,
                uri: message['uri'],
              );

            } else {
              return types.TextMessage(
                author: author,

                id: message['_id'].toString(),
                text: text,
              );
            }
          }).toList();

          setState(() {

            _messages = List.from(messages);
            print(_messages);// Ensure a new list reference
          });

          print('Messages loaded successfully.');
        } else {
          print('Invalid or missing "messages" field in the response body.');
        }
      } catch (e) {
        print('Error decoding the response: $e');
      }
      // finally {
      //   EasyLoading.dismiss(); // Hide loading indicator
      // }
    } else {
      print('Failed to load messages. Status code: ${response.statusCode}');
    }

  }


  Future<String> _fetchReceiverName() async {
    final apiUrl = 'http://localhost:8081/message'; // Adjust the URL to your API endpoint

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'myid': widget.fromId,
          'otherid': widget.toId,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> messages = jsonDecode(response.body)['messages'];
        if (messages.isNotEmpty) {
          final Map<String, dynamic> lastMessage = messages.last;
          print(lastMessage);
          final String receiverName =
              lastMessage['from']['name'] ?? 'Receiver Name';
          return receiverName;
        } else {
          print('No messages found for the user.');
          return 'Receiver Name'; // Default value or handle as needed
        }
      } else {
        print('Failed to fetch receiver name. Status code: ${response.statusCode}');
        return 'Receiver Name'; // Default value or handle error as needed
      }
    } catch (e) {
      print('Error fetching receiver name: $e');
      return 'Receiver Name'; // Default value or handle error as needed
    }
  }








  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.blueAccent,
      centerTitle: true,
      title: Text(widget.receiverName,
        style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30,fontStyle: FontStyle.italic),
      ),
    ),
    // appBar: AppBar(
    //   title: FutureBuilder<String>(
    //     future: _receiverName,
    //     builder: (context, snapshot) {
    //       if (snapshot.connectionState == ConnectionState.waiting) {
    //         return CircularProgressIndicator();
    //       } else if (snapshot.hasError) {
    //         return Text('Error loading receiver name');
    //       } else {
    //         return Text(snapshot.data ?? 'Receiver Name');
    //       }
    //     },
    //   ),
    // ),

    body:
    SwipeTo(
      onLeftSwipe: (details) {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final localPosition = renderBox.globalToLocal(details.globalPosition);

        // Find the tapped message based on the local position
        final tappedMessage = _findTappedMessage(localPosition);

        // Show a bottom sheet or perform any action based on the tapped message
        _displayInputBottomSheet(tappedMessage as bool);
      },
      child: Chat(
        key: Key('chat'),
        messages: _messages,
        onAttachmentPressed: _handleAttachmentPressed,
        onMessageTap: _handleMessageTap,
        onPreviewDataFetched: _handlePreviewDataFetched,
        onSendPressed: _handleSendPressed,
        showUserAvatars: false,
        showUserNames: true,
        user: _user,
        //messageKeyBuilder: (String messageId, _) => messageKeys[messageId],
      ),
    ),


  );
  types.Message? _findTappedMessage(Offset localPosition) {
    for (final message in _messages) {
      final RenderBox messageRenderBox = messageKeys[message.id]!.currentContext!.findRenderObject() as RenderBox;
      final messagePosition = messageRenderBox.localToGlobal(Offset.zero);

      final messageSize = messageRenderBox.size;
      final messageRect = Rect.fromPoints(messagePosition, Offset(messagePosition.dx + messageSize.width, messagePosition.dy + messageSize.height));

      if (messageRect.contains(localPosition)) {
        return message;
      }
    }
    return null;
  }


  // _displayInputBottomSheet(bool isRightSwipe) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (context) {
  //       return Padding(
  //         padding: MediaQuery.of(context).viewInsets,
  //         child: Container(
  //           padding: const EdgeInsets.only(
  //             left: 16.0,
  //             right: 16.0,
  //             top: 16.0,
  //             bottom: 16.0,
  //           ),
  //           child: TextField(
  //             autofocus: true,
  //             textInputAction: TextInputAction.done,
  //             textCapitalization: TextCapitalization.words,
  //             onSubmitted: (value) => _handleSwipeReply(
  //               isRightSwipe: isRightSwipe ? true : false,
  //               reply: value,
  //             ),
  //             decoration: const InputDecoration(
  //               labelText: 'Reply',
  //               hintText: 'enter reply here',
  //               border: OutlineInputBorder(
  //                 borderRadius: BorderRadius.all(
  //                   Radius.circular(5.0),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  // types.Message? _findTappedMessage(Offset localPosition) {
  //   for (final message in _messages) {
  //     final RenderBox messageRenderBox = messageKeys[message.id]!.currentContext!.findRenderObject() as RenderBox;
  //     final messagePosition = messageRenderBox.localToGlobal(Offset.zero);
  //
  //     final messageSize = messageRenderBox.size;
  //     final messageRect = Rect.fromPoints(messagePosition, messagePosition + messageSize);
  //
  //     if (messageRect.contains(localPosition)) {
  //       return message;
  //     }
  //   }
  //   return null;
  // }


  void _displayInputBottomSheet(bool isRightSwipe) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: 16.0,
            ),
            child: TextField(
              autofocus: true,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              onSubmitted: (value) => _handleSwipeReply(
                isRightSwipe: isRightSwipe,
                reply: value,
              ),
              decoration: const InputDecoration(
                labelText: 'Reply',
                hintText: 'enter reply here',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5.0),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      // You can handle completion logic here if needed
    });
  }

  void _handleSwipeReply({
    required bool isRightSwipe,
    required String reply,
  }) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          reply,
          textAlign: TextAlign.center,
        ),
        backgroundColor: isRightSwipe ? Colors.red.shade600 : Colors.green.shade600,
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }


}

