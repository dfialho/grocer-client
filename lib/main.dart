import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

enum ReceiptStatus { unprocessed, processing, processed, warning }

@immutable
class Receipt {
  final String id = const Uuid().v4();
  final String name;
  final String store;
  final int amount;
  final DateTime date;
  final ReceiptStatus status;

  Receipt(this.name, this.store, this.amount, this.date, this.status);
}

class ReceiptListModel {
  final List<Receipt> receipts = [
    Receipt("Receipt A", "Continente", 100, DateTime(2022, 10, 11),
        ReceiptStatus.warning),
    Receipt("Receipt B", "Continente Online", 100, DateTime(2022, 10, 10),
        ReceiptStatus.processing),
    Receipt("Receipt C", "Continente", 100, DateTime(2022, 10, 11),
        ReceiptStatus.processed),
    Receipt("Receipt D", "Continente", 100, DateTime(2022, 10, 11),
        ReceiptStatus.unprocessed),
    Receipt("Receipt E", "Continente", 100, DateTime(2022, 10, 11),
        ReceiptStatus.processed),
    Receipt(
        "Receipt FReceipt AReceipt AReceipt AReceipt AReceipt A A A A A A A A A A A A A A",
        "Continente Continente Continente Continente Continente Continente Continente Continente A A A A  A A A A A A A",
        100,
        DateTime(2022, 10, 11),
        ReceiptStatus.processed),
    Receipt("Receipt G", "Continente", 100, DateTime(2022, 10, 11),
        ReceiptStatus.processed),
  ];

  int size() {
    return receipts.length;
  }

  Receipt get(int index) {
    return receipts[index];
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    final receiptList = ReceiptListModel();

    return MaterialApp(
      title: "Grocer",
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Receipts"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: ListView.builder(
            itemCount: receiptList.size(),
            itemBuilder: (context, index) {
              return Column(
                children: [
                  _ReceiptWidget(receiptList.get(index)),
                  const SizedBox(height: 5,)
                ],
              );
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
  }}
