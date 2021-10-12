import 'package:flutter/material.dart';
import 'dart:async';
import 'package:telephony/telephony.dart';
import 'package:intl/intl.dart';

class Homepage extends StatefulWidget {
  Function backgroundHandler;
  Homepage(this.backgroundHandler, {Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final telephony = Telephony.instance;
  List<SmsMessage> messages = <SmsMessage>[];
  List<SmsMessage> mpesaMessages = <SmsMessage>[];
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  onMessage(SmsMessage message) async {
    mpesaMessages.add(message);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    final bool? result = await telephony.requestPhoneAndSmsPermissions;

    if (result != null && result) {
      telephony.listenIncomingSms(
          onNewMessage: onMessage,
          onBackgroundMessage: (widget.backgroundHandler) as dynamic);
    }

    if (!mounted) return;
  }

  convertDate(String date) {
    int timeInMiliseconds = int.parse((date));
    var time = DateTime.fromMillisecondsSinceEpoch(timeInMiliseconds);
    var formattedDate = DateFormat.yMMMMd().add_jm().format(time);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SMS Inbox"),
        backgroundColor: Colors.pink,
      ),
      body: FutureBuilder(
        future: fetchSMS(),
        builder: (context, snapshot) {
          if (mpesaMessages.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return ListView.separated(
                separatorBuilder: (context, index) => const Divider(
                      color: Colors.black,
                    ),
                itemCount: mpesaMessages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () => {
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => MpesaMessageScreen(
                        //             (mpesaMessages[index]) as dynamic)))
                      },
                      child: ListTile(
                        leading: const Icon(
                          Icons.markunread,
                          color: Colors.pink,
                        ),
                        title: Text((mpesaMessages[index].address).toString()),
                        subtitle: Column(
                          children: [
                            Text(
                              (mpesaMessages[index].body).toString(),
                              maxLines: 2,
                              style: const TextStyle(),
                            ),
                            Text(convertDate(
                                (mpesaMessages[index].date).toString())),
                          ],
                        ),
                      ),
                    ),
                  );
                });
          }
        },
      ),
    );
  }

  fetchSMS() async {
    messages = await Telephony.instance.getInboxSms(
      columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
    );
    for (var message in messages) {
      mpesaMessages.add(message);
    }
    mpesaMessages;
  }
}
