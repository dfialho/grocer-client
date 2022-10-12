import 'package:flutter/material.dart';

import '../models/receipt.dart';
import 'receipt-items.dart';

class ReceiptsScreen extends StatelessWidget {
  const ReceiptsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final receiptList = ReceiptListModel();

    return MaterialApp(
      title: "Grocer",
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Receipts'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: RefreshIndicator(
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              onRefresh: receiptList.refresh,
              child: FutureBuilder<List<Receipt>>(
                  future: receiptList.receipts,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return StreamBuilder<List<Receipt>>(
                          initialData: snapshot.data,
                          stream: receiptList.stream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return ReceiptListWidget(snapshot.data!);
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

                    return const CircularProgressIndicator();
                  }),
            )),
      ),
    );
  }
}

class ReceiptListWidget extends StatelessWidget {
  const ReceiptListWidget(this.receipts, {super.key});

  final List<Receipt> receipts;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: receipts.length,
      itemBuilder: (context, index) {
        final receipt = receipts[index];
        return Column(
          children: [
            GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ReceiptItemsScreen(receipt)));
                },
                child: _ReceiptWidget(receipt)),
            const SizedBox(height: 5)
          ],
        );
      },
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
