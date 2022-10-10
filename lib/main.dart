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

Future<List<Receipt>> fetchReceipts() async {
  final response =
      await http.get(Uri.parse('http://localhost:8080/receipts/3fa85f64-5717-4562-b3fc-2c963f66afa6'));

  if (response.statusCode == 200) {
    return [Receipt.fromJson(jsonDecode(response.body))];
  } else {
    throw Exception('Failed to load receipts');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Receipt>> futureReceipts;

  @override
  void initState() {
    super.initState();
    futureReceipts = fetchReceipts();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Grocer",
      home: Scaffold(
        appBar: AppBar(
          title: TextButton(
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            ),
            onPressed: () { },
            child: Text('Receipts'),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: FutureBuilder<List<Receipt>>(
            future: futureReceipts,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final receiptList = snapshot.data!;
                return ListView.builder(
                  itemCount: receiptList.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        _ReceiptWidget(receiptList[index]),
                        const SizedBox(
                          height: 5,
                        )
                      ],
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
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
