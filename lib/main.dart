import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

enum ReceiptStatus { unprocessed, processing, processed, warning }

class Receipt {
  String name;
  String store;
  int amount;
  DateTime date;
  ReceiptStatus status;

  Receipt(this.name, this.store, this.amount, this.date, this.status);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Grocer",
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Receipts"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              buildReceipt(Receipt("Receipt A", "Continente", 100,
                  DateTime(2022, 10, 11), ReceiptStatus.warning)),
              const SizedBox(height: 5.0),
              buildReceipt(Receipt("Receipt B", "Continente Online", 100,
                  DateTime(2022, 10, 10), ReceiptStatus.processing)),
              const SizedBox(height: 5.0),
              buildReceipt(Receipt("Receipt C", "Continente", 100,
                  DateTime(2022, 10, 11), ReceiptStatus.processed)),
              const SizedBox(height: 5.0),
              buildReceipt(Receipt("Receipt D", "Continente", 100,
                  DateTime(2022, 10, 11), ReceiptStatus.unprocessed)),
              const SizedBox(height: 5.0),
              buildReceipt(Receipt("Receipt E", "Continente", 100,
                  DateTime(2022, 10, 11), ReceiptStatus.processed)),
              const SizedBox(height: 5.0),
              buildReceipt(Receipt("Receipt F", "Continente", 100,
                  DateTime(2022, 10, 11), ReceiptStatus.processed)),
              const SizedBox(height: 5.0),
              buildReceipt(Receipt("Receipt G", "Continente", 100,
                  DateTime(2022, 10, 11), ReceiptStatus.processed)),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildReceipt(Receipt receipt) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receipt.name,
                      style: const TextStyle(fontSize: 20.0),
                    ),
                    Text(receipt.store)
                  ],
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
