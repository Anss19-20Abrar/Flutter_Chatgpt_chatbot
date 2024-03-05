import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:virtual_psychiatrist_app/consts.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _openAI = OpenAI.instance.build(
    token: OPENAI_API_KEY,
    baseOption: HttpSetup(
      receiveTimeout: const Duration(
        seconds: 5,
      ),
    ),
    enableLog: true,
  );

  final ChatUser _currentUser =
      ChatUser(id: '1', firstName: 'Hussain', lastName: 'Mustafa');

  final ChatUser _gptChatUser =
      ChatUser(id: '2', firstName: 'Chat', lastName: 'GPT');

  List<ChatMessage> _messages = <ChatMessage>[];
  List<ChatUser> _typingUsers = <ChatUser>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(
          0,
          166,
          126,
          1,
        ),
        title: const Text(
          'GPT Chat',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: DashChat(
          currentUser: _currentUser,
          typingUsers: _typingUsers,
          messageOptions: const MessageOptions(
            currentUserContainerColor: Colors.black,
            containerColor: Color.fromRGBO(
              0,
              166,
              126,
              1,
            ),
            textColor: Colors.white,
          ),
          onSend: (ChatMessage m) {
            getChatResponse(m);
          },
          messages: _messages),
    );
  }

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      _messages.insert(0, m);
      _typingUsers.add(_gptChatUser);
    });
    List<Messages> _messagesHistory = _messages.reversed.map((m) {
      if (m.user == _currentUser) {
        return Messages(role: Role.user, content: m.text);
      } else {
        return Messages(role: Role.assistant, content: m.text);
      }
    }).toList();
    final request = ChatCompleteText(
      model: GptTurbo0301ChatModel(),
      messages: _messagesHistory,
      maxToken: 200,
    );
    final response = await _openAI.onChatCompletion(request: request);
    for (var element in response!.choices) {
      if (element.message != null) {
        setState(() {
          _messages.insert(
            0,
            ChatMessage(
                user: _gptChatUser,
                createdAt: DateTime.now(),
                text: element.message!.content),
          );
        });
      }
    }
    setState(() {
      _typingUsers.remove(_gptChatUser);
    });
  }
}







// ***  easy understanding code with proper exceptions   ***



// class ChatPage extends StatefulWidget {
//   const ChatPage({super.key});

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final ChatUser _currentUser =
//       ChatUser(id: '1', firstName: 'You', lastName: '');
//   final ChatUser _gptChatUser =
//       ChatUser(id: '2', firstName: 'Chat', lastName: 'GPT');

//   List<ChatMessage> _messages = [];
//   List<ChatUser> _typingUsers = [];

//   OpenAI? _openAI;

//   @override
//   void initState() {
//     super.initState();
//     _initializeOpenAI();
//   }

//   Future<void> _initializeOpenAI() async {
//     try {
//       _openAI = OpenAI.instance.build(
//         token: OPENAI_API_KEY, // Use the constant from consts.dart
//         baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 5)),
//         enableLog: true,
//       );
//     } catch (e) {
//       // Handle errors gracefully, e.g., display an error message
//       print("Error initializing OpenAI: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           backgroundColor: Colors.red,
//           content: Text('Error initializing OpenAI: $e'),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color.fromRGBO(0, 166, 126, 1),
//         title: const Text('ChatGPT'),
//       ),
//       body: _openAI != null
//           ? DashChat(
//               currentUser: _currentUser,
//               messages: _messages,
//               typingUsers: _typingUsers,
//               messageOptions: const MessageOptions(
//                 currentUserContainerColor: Colors.black,
//                 containerColor: Color.fromRGBO(0, 166, 126, 1),
//                 textColor: Colors.white,
//               ),
//               onSend: (ChatMessage message) =>
//                   _handleSendMessage(message), // Use a concise function name
//             )
//           : const Center(child: CircularProgressIndicator()),
//     );
//   }

//   Future<void> _handleSendMessage(ChatMessage message) async {
//     setState(() {
//       _messages.insert(0, message);
//       _typingUsers.add(_gptChatUser); // Simulate GPT typing
//     });

//     if (_openAI != null) {
//       await _getChatResponse(message);
//     } else {
//       print("OpenAI not initialized yet, cannot send message");
//     }
//   }

//   Future<void> _getChatResponse(ChatMessage message) async {
//     final request = ChatCompleteText(
//       model: GptTurbo0301ChatModel(),
//       messages: _messages.reversed.map((m) {
//         if (m.user == _currentUser) {
//           return Messages(role: Role.user, content: m.text);
//         } else {
//           return Messages(role: Role.assistant, content: m.text);
//         }
//       }).toList(),
//       maxToken: 200,
//     );

//     try {
//       final response = await _openAI!.onChatCompletion(request: request);
//       for (var element in response!.choices) {
//         if (element.message != null) {
//           setState(() {
//             _messages.insert(
//               0,
//               ChatMessage(
//                 user: _gptChatUser,
//                 createdAt: DateTime.now(),
//                 text: element.message!.content,
//               ),
//             );
//           });
//         }
//       }
//     } catch (e) {
//       // Handle API errors gracefully, e.g., display an error message
//       print("Error getting response from OpenAI: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           backgroundColor: Colors.red,
//           content: Text('Error getting response from OpenAI: $e'),
//         ),
//       );
//     }
//   }
// }



// end 
