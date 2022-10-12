import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

enum ReceiptStatus {
  unprocessed,
  processing,
  processed,
  warning;
}

@immutable
class Receipt {
  final String id;
  final String name;
  final String store;
  final int amount;
  final DateTime date;
  final ReceiptStatus status;

  const Receipt(
      this.id, this.name, this.store, this.amount, this.date, this.status);

  static Receipt fromJson(Map<String, dynamic> json) {
    return Receipt(json['id'], json['name'], json['store'], json['amount'],
        DateTime.now(), ReceiptStatus.processed);
  }
}

class ReceiptListModel {
  Stream<List<Receipt>> get stream {
    return _stream.stream;
  }

  final _stream = StreamController<List<Receipt>>();

  Future<void> refresh() async {
    print("Refresh");
    final receipts = await fetchReceipts();
    _stream.addStream(Stream.value(receipts));
    print("Refreshed");
  }
}

Future<List<Receipt>> fetchReceipts() async {
  print("Fetching receipts...");
  final response = await http.get(Uri.parse('http://localhost:8080/receipts'));
  print("Fetched receipts");

  if (response.statusCode == 200) {
    return List.from(jsonDecode(response.body).map((e) => Receipt.fromJson(e)));
  } else {
    throw Exception('Failed to load receipts');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Grocer",
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Receipts'),
        ),
        body: _ReceiptListWidget(),
      ),
    );
  }
}

class _ReceiptListWidget extends StatelessWidget {
  const _ReceiptListWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final receiptList = ReceiptListModel();

    return Padding(
        padding: const EdgeInsets.all(15.0),
        child: RefreshIndicator(
          triggerMode: RefreshIndicatorTriggerMode.anywhere,
          onRefresh: receiptList.refresh,
          child: FutureBuilder<List<Receipt>>(
              future: fetchReceipts(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return StreamBuilder<List<Receipt>>(
                      initialData: snapshot.data,
                      stream: receiptList.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final receipts = snapshot.data!;

                          return ListView.builder(
                            itemCount: receipts.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  _ReceiptWidget(receipts[index]),
                                  const SizedBox(height: 5)
                                ],
                              );
                            },
                          );
                        }

                        if (snapshot.hasError) {
                          return Text("ERROR - ${snapshot.error}");
                        }

                        return const CircularProgressIndicator();
                      });
                }

                if (snapshot.hasError) {
                  return Text("ERROR - ${snapshot.error}");
                }

                return const RefreshProgressIndicator();
              }),
        ));
  }
}

class _ReceiptWidget extends StatelessWidget {
  const _ReceiptWidget(this.receipt);

  final Receipt receipt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 50.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          receipt.name,
                          style: const TextStyle(fontSize: 20.0),
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                        Text(
                          receipt.store,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        )
                      ],
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${receipt.amount}.00€",
                      style: const TextStyle(fontSize: 20.0),
                    ),
                    Text(
                        "${receipt.date.day}-${receipt.date.month}-${receipt.date.year}")
                  ],
                ),
              ],
            ),
          ),
          Container(
            // color: Colors.yellow,
            margin: const EdgeInsets.only(left: 10),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: Text(
                  statusToEmoji(receipt.status),
                  style: const TextStyle(fontSize: 30.0),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  String statusToEmoji(ReceiptStatus status) {
    switch (status) {
      case ReceiptStatus.processed:
        return "🟢";
      case ReceiptStatus.processing:
        return "🔵";
      case ReceiptStatus.unprocessed:
        return "🟤";
      case ReceiptStatus.warning:
        return "🟡";
    }
  }
}
