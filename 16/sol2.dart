import 'dart:io';
import 'dart:convert';
import 'dart:async';

main() async {
    final file = new File('prob.in');
    Stream<List<int>> inputStream = file.openRead();

    final lineStream = inputStream
        .transform(utf8.decoder)       // Decode bytes to UTF-8.
        .transform(new LineSplitter()) // Convert stream to individual lines.
        .asBroadcastStream();

    final fieldNums = await lineStream
        .takeWhile((String line) => line.contains(": "))
        // "class: 1-3 or 5-7" => [["class", [1, 2, 3, 5, 7]]
        .map((String line) {
            var parts = line.split(": ");
            return MapEntry(
                parts[0],
                parts[1]
                    .split(" or ")
                    .expand((range) {
                        // "5-7" => [5, 6, 7]
                        var lohi = range.split("-").map(int.parse).toList();
                        return List.generate(lohi[1] - lohi[0] + 1, (index) => lohi[0] + index);
                    })
            );
        })
        .toList()
        .then((list) => Map.fromEntries(list));

    var myTicket = await lineStream
        .skipWhile((line) => !line.contains("your ticket:"))
        .skip(1)
        .first;
    print(myTicket);

    var allValidNums = fieldNums.values.expand((list) => list).toSet();

    final validTickets = await lineStream
            .skipWhile((line) => !line.contains("nearby"))
            .skip(1)
            .map((line) => line.split(",").map(int.parse).toList())
            .where((nums) {
                var valid = nums.every(allValidNums.contains);
                return valid;
            })
            .toList();

    var allIndexes = List.generate(fieldNums.length, (index) => index);
    print(fieldNums);
    print(validTickets);
    var possibleFieldIndexes = fieldNums.map((field, validNums) {
        var goodIndexes = allIndexes
            .where((index) => validTickets.map((ticket) => ticket[index]).every(validNums.contains))
            .toSet();
        return MapEntry(field, goodIndexes);
    }).entries.toList();
    possibleFieldIndexes.sort((kv1, kv2) => kv1.value.length.compareTo(kv2.value.length));
    print(possibleFieldIndexes);
    var assignedFieldIndexes = Map.fromIterable(allIndexes, key: (index) => index, value: (index) => "");
    possibleFieldIndexes.forEach((kv) {
        var remainingIndexes = assignedFieldIndexes
            .entries
            .where((kv) => kv.value == "")
            .map((kv) => kv.key)
            .toSet();
        var validIndexes = kv.value.intersection(remainingIndexes);
        print([kv.key, validIndexes, assignedFieldIndexes]);
        if (validIndexes.length == 0) {
            throw("${kv.key} has no valid indexes");
        }
        if (validIndexes.length > 1) {
            throw("${kv.key} has too many indexes: $validIndexes");
        }
        assignedFieldIndexes[validIndexes.first] = kv.key;
    });
    print(assignedFieldIndexes);


    var myNums = myTicket.split(",").map(int.parse).toList();
    var result = assignedFieldIndexes
        .entries
        .where((kv) => kv.value.contains("departure"))
        .map((kv) => myNums[kv.key])
        .toList();
    print([result, result.reduce((a, b) => a * b)]);
}

