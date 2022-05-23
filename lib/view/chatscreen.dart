import 'package:flutter/material.dart';
import 'package:localchathistory/data/databasehelper.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List chatData = [];
  TextEditingController txtController = TextEditingController();
  bool isDataLoading = false;
  ScrollController? scrollController;
  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()..addListener(handleScrolling);

    getChatData();
  }

  void handleScrolling() {
    if (scrollController!.offset >=
        scrollController!.position.maxScrollExtent) {
      print("scroll handling called");
      setState(() {
        getChatData();
      });
    }
  }

  @override
  void dispose() {
    scrollController!.removeListener(handleScrolling);
    super.dispose();
  }

  getChatData() async {
    setState(() {
      isDataLoading = true;
    });
    chatData = await databaseHelper.getChatData();
    setState(() {
      isDataLoading = false;
    });
    print("the value of chat data is $chatData");
  }

  @override
  Widget build(BuildContext context) {
    const double minValue = 8.0;

    insertChatRecord(Map<String, dynamic> messageData) {
      databaseHelper.insertChatMessage(messageData).then((value) {
        print("the helper is $value");
        if (value == null) {
          getChatData();
          setState(() {});
        }
      });
    }

    void _scrollDown() {
      scrollController!.jumpTo(scrollController!.position.maxScrollExtent);
    }

    Widget _buildBottomSection() {
      return Row(
        children: <Widget>[
          Expanded(
            child: Container(
              height: 52,
              margin: const EdgeInsets.all(minValue),
              padding: const EdgeInsets.symmetric(horizontal: minValue),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.all(Radius.circular(minValue * 4))),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.text,
                      controller: txtController,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Type your message"),
                      autofocus: false,
                    ),
                  ),
                  IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        if (txtController.text.isNotEmpty) {
                          Map<String, dynamic> enteredMessage = {
                            "description": txtController.text,
                          };
                          insertChatRecord(enteredMessage);
                          txtController.clear();
                          _scrollDown();
                        }
                      }),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
              child: isDataLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      reverse: true,
                      controller: scrollController,
                      itemCount: chatData.length,
                      itemBuilder: (context, index) {

                        return Container(
            margin: const EdgeInsets.only(top: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                 
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.6),
                      decoration: BoxDecoration(
                          color:  Colors.grey[200],
                          borderRadius: const BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: Radius.circular(16),
                            bottomLeft: Radius.circular( 12 ),
                            bottomRight: Radius.circular( 12),
                          )),
                      child: Text(
                        chatData[index]['description'],
                        style: TextStyle(
                            color:  Colors.grey[800]),
                      ),
                    ),
                  ],
                ),
           
              ],
            ),
          );

                  
                      })),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomSection(),
          ),
        ],
      ),
    );
  }
}

