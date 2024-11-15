import 'package:chat_app/models/message.dart';
import 'package:chat_app/providers/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  Future<void> _sendMessageToGemini() async {
    final apiKey = dotenv.env['GOOGLE_API_KEY']!;
    if (apiKey.isEmpty) {
      throw Exception('GOOGLE_API_KEY is not set');
    }

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(maxOutputTokens: 100),
    );

    final userMessage = _messageController.text;
    setState(() {
      _messages.add(Message(text: userMessage, isUser: true));
      _isSending = true;
    });
    _messageController.clear();

    final content = Content.text(userMessage);
    final responseStream = model.generateContentStream([content]);

    StringBuffer responseBuffer = StringBuffer();

    await for (final chunk in responseStream) {
      responseBuffer.write(chunk.text);
      setState(() {
        // 更新最后一条消息的内容
        if (_messages.isNotEmpty && !_messages.last.isUser) {
          _messages.last =
              Message(text: responseBuffer.toString(), isUser: false);
        } else {
          _messages
              .add(Message(text: responseBuffer.toString(), isUser: false));
        }
      });
    }

    setState(() {
      _isSending = false;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Image(
                  image: AssetImage('assets/images/robot.png'),
                ),
                const SizedBox(width: 10),
                Text(
                  'Gemini',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                ref.read(themeNotifierProvider.notifier).toggleTheme();
              },
              child: Icon(
                currentTheme == ThemeModeState.light
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Align(
                    alignment:
                        message.isUser ? Alignment.topRight : Alignment.topLeft,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: message.isUser
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                        borderRadius: message.isUser
                            ? const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              )
                            : const BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                              ),
                      ),
                      child: Text(
                        message.text,
                        style: message.isUser
                            ? Theme.of(context).textTheme.bodyMedium
                            : Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 32.0),
            child: Container(
              decoration: BoxDecoration(
                color: currentTheme == ThemeModeState.light
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.1),
                    blurRadius: 2,
                    spreadRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onSubmitted: (value) => _sendMessageToGemini(),
                      style: Theme.of(context).textTheme.titleSmall,
                      decoration: InputDecoration(
                        hintText: 'Write your message...',
                        hintStyle:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () => _sendMessageToGemini(),
                      child: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                              ),
                            )
                          : Image.asset(
                              'assets/images/send.png',
                              width: 20,
                              height: 20,
                            ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
