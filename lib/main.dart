import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'dart:math';

void main() {
  runApp(
    const MaterialApp(
      title: 'Employees Management Application',
      home: Homepage(),
    ),
  );
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<List<dynamic>>? csvData;
  int _pageNumber = 1;
  int _totalPages = 1;
  Future<List<List<dynamic>>> processCsv() async {
    var result = await DefaultAssetBundle.of(context).loadString(
      "assets/database.csv",
    );
    return const CsvToListConverter().convert(result, eol: "\n");
  }

  @override
  void initState() {
    super.initState();
    //debugPrint('Initialized');
    fetchCSVData();
    //debugPrint('Done');
    //debugPrint(DateTime.parse('2015-06-26 00:00:00').toString());
  }

  void fetchCSVData() async {
    csvData = await processCsv();
    _totalPages = ((csvData!.length + 19) ~/ 20);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employees Data"),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: csvData == null
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
                child: Column(
                  children: [
                    DataTable(
                      headingRowColor: MaterialStateProperty.resolveWith(
                          (states) => Colors.black87),
                      columns: csvData![0]
                          .map(
                            (item) => DataColumn(
                              label: Text(
                                item.toString(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                          )
                          .toList(),
                      rows: csvData!
                          .sublist(1 + (_pageNumber - 1) * 20,
                              min(_pageNumber * 20, csvData!.length))
                          .map(
                            (csvrow) => DataRow(
                              color: DateTime.parse(csvrow[5]
                                          .toString()
                                          .replaceAll(
                                              RegExp('[^A-Za-z0-9]'), ''))
                                      .isBefore(DateTime(
                                          DateTime.now().year - 5,
                                          DateTime.now().month,
                                          DateTime.now().day))
                                  ? MaterialStateProperty.resolveWith(
                                      (states) => Colors.green[300])
                                  : MaterialStateProperty.resolveWith(
                                      (states) => Colors.blue[100]),
                              cells: csvrow
                                  .map(
                                    (csvItem) => DataCell(
                                      Text(
                                        csvItem.toString(),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          )
                          .toList(),
                    ),
                    Container(
                      height: 30,
                      width: 120,
                      decoration: BoxDecoration(border: Border.all(width: 1)),
                      child: TextFormField(
                        initialValue: _pageNumber.toString(),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            prefix: const Text('Page '),
                            suffix: Text(' / $_totalPages'),
                            hintStyle:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        onChanged: (val) => setState(() {
                          int temp = int.tryParse(val) ?? 1;
                          if (temp >= 1 && temp <= _totalPages) {
                            _pageNumber = temp;
                          }
                        }),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
