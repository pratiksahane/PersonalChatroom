import 'package:chatpt/SigninPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MaterialApp(home: Home()));
  } catch (e) {
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Failed to initialize Firebase: $e'),
        ),
      ),
    ));
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<Map<String, dynamic>> _messages = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _messagesSubscription;
  User? _currentUser;

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SigninPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _loadMessages();
  }

  void _loadMessages() {
    _messagesSubscription = _firestore
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _messages.clear();
          for (var doc in snapshot.docs) {
            _messages.add({
              'text': doc['text'],
              'senderId': doc['senderID'],
              'senderName': doc['senderName'] ?? 'Anonymous',
              'timestamp': doc['timestamp'],
            });
          }
        });
      }
    }, onError: (error) {
      debugPrint('Error loading messages: $error');
    });
  }

  Future<void> _sendMessage() async {
  if (_messageController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Message cannot be empty')),
    );
    return;
  }

  if (_currentUser == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You must be logged in to send messages')),
    );
    return;
  }

  try {
    await _firestore.collection('messages').add({
      'text': _messageController.text,
      'senderID': _currentUser!.uid, // Must match security rules
      'senderName': _currentUser!.displayName ?? 
                   _currentUser!.email?.split('@')[0] ?? 
                   'Anonymous',
      'timestamp': FieldValue.serverTimestamp(),
    });
    _messageController.clear();
  } on FirebaseException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to send: ${e.message}')),
    );
    debugPrint('Firestore error: ${e.code} - ${e.message}');
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An unexpected error occurred')),
    );
    debugPrint('Error: $e');
  }
}
  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isCurrentUser = message['senderId'] == _currentUser?.uid;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: isCurrentUser 
            ? CrossAxisAlignment.end 
            : CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 4),
              child: Text(
                message['senderName'],
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Align(
            alignment: isCurrentUser 
                ? Alignment.centerRight 
                : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCurrentUser 
                    ? const Color.fromRGBO(51, 105, 255, 1.0)
                    : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: isCurrentUser 
                      ? const Radius.circular(12)
                      : const Radius.circular(4),
                  bottomRight: isCurrentUser 
                      ? const Radius.circular(4)
                      : const Radius.circular(12),
                ),
              ),
              child: Text(
                message['text'],
                style: TextStyle(
                  color: isCurrentUser ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.grey[300],
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            "assets/images/logo2.png",
            height: 36,
            fit: BoxFit.contain,
          ),
        ),
        title: const Text(
          "ChatGPT",
          style: TextStyle(
            color: Color.fromRGBO(51, 105, 255, 1.0),
            fontFamily: "Nunito",
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(
            height: 1,
            thickness: 2,
            color: Colors.grey[300],
          ),
        ),
        actions: [
          IconButton(
            onPressed: _logout, 
            icon: Icon(
              Icons.logout_rounded,
              color: Color.fromRGBO(51, 105, 255, 1.0),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Material(
              elevation: 2.0,
              borderRadius: BorderRadius.circular(24.0),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: _sendMessage,
                    icon: Icon(
                      Icons.send_rounded,
                      color: const Color.fromRGBO(51, 105, 255, 1.0),
                    ),
                  ),
                  hintText: "Type your message...",
                  hintStyle: const TextStyle(
                    color: Color.fromRGBO(51, 105, 255, 1.0),
                    fontFamily: "Nunito",
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}