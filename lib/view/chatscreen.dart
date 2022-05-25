import 'package:flutter/material.dart';
import 'package:localchathistory/data/chatdata.dart';
import 'package:localchathistory/data/databasehelper.dart';
import 'package:intl/intl.dart';
import 'package:localchathistory/data/sharedprefrenceconst.dart';
import 'package:localchathistory/utils/commonutlis.dart';

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
  int totalchatCount = 0;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()..addListener(handleScrolling);

    isFetchLoadData();
  }

  isFetchLoadData() async {
    setState(() {
      isDataLoading = true;
    });
    int? isDbCreated = CommonUtils.sharedPreferences
        .getInt(SharedPrefrenceConstant.isDbCreated);

    if (isDbCreated != null && isDbCreated == 1) {
      await databaseHelper.saveChatResult(ChatData.chatData);
      await CommonUtils.sharedPreferences
          .setInt(SharedPrefrenceConstant.isDbCreated, 0);

      getChatData();
    } else {
      getChatData();
    }
  }

  getChatData() async {
    await getchatCount();
    List<Map<String, dynamic>> _chatDatas = await getRecentChatList(0);
    chatData = _chatDatas;
    if (mounted) {
      setState(() {
        isDataLoading = false;
      });
    }
  }

  void handleScrolling() {
    if (scrollController!.position.pixels ==
        scrollController!.position.maxScrollExtent) {
      getRecentChatList(chatData.length).then((chatvalue) {
        setState(() {
          chatData.addAll(chatvalue);
        });
      });
    }
  }

  Future<List<Map<String, dynamic>>> getRecentChatList(int offset) async {
    List<Map<String, dynamic>> chatlists =
        await databaseHelper.fetchChatMessage(
      limit: offset,
    );

    return chatlists;
  }

  @override
  void dispose() {
    scrollController!.removeListener(handleScrolling);
    super.dispose();
  }

  Future<void> getchatCount() async {
    totalchatCount = await databaseHelper.getmessageCount();
    if (mounted) {
      setState(() {});
    }
  }

  insertChatRecord(Map<String, dynamic> messageData) {
    databaseHelper.insertChatMessage(messageData).then((value) {
      if (value == null) {
        getChatData();
        setState(() {});
      }
    });
  }

  //Used to jump to bottom of the list

  void scrollToBottom() {
    final bottomOffset = scrollController!.position.minScrollExtent;
    scrollController!.animateTo(
      bottomOffset,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildBottomSection() {
    const double minValue = 8.0;

    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: 52,
            margin: const EdgeInsets.all(minValue),
            padding: const EdgeInsets.symmetric(horizontal: minValue),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(minValue * 4))),
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
                          "createdon":
                              DateFormat.jm().format(DateTime.now()).toString(),
                        };
                        insertChatRecord(enteredMessage);
                        scrollToBottom();
                        txtController.clear();
                      }
                    }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
        title: const Text(
          "Chat Message",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
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
                        print("the value of data");
                        return Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.6),
                                    decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                          bottomLeft: Radius.circular(12),
                                          bottomRight: Radius.circular(12),
                                        )),
                                    child: Text(
                                      "${chatData[index]['description']}   ${chatData[index]['createdon']} ",
                                      style: TextStyle(color: Colors.grey[800]),
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
