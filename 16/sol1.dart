import 'dart:io';
import 'dart:convert';
import 'dart:async';

main() {
    final file = new File('prob.in');
    Stream<List<int>> inputStream = file.openRead();

    final lineStream = inputStream
        .transform(utf8.decoder)       // Decode bytes to UTF-8.
        .transform(new LineSplitter()) // Convert stream to individual lines.
        .asBroadcastStream();

    final validNums = lineStream
        .takeWhile((String line) => line.contains(": "))
        // "class: 1-3 or 5-7" => ["1-3", "5-7"]
        .expand((String line) => line.split(": ")[1].split(" or "))
        // "5-7" => [5, 6, 7]
        .expand((String range) {
            var lohi = range.split("-").map(int.parse).toList();
            return List.generate(lohi[1] - lohi[0] + 1, (index) => lohi[0] + index);
        })
        .toSet();

    validNums.then((validNums) {
        return lineStream
            .skipWhile((line) => !line.contains("nearby"))
            .skip(1)
            .expand((String line) {
                print("ticket $line");
                var nums = line.split(",").map(int.parse);
                var valid = nums.every(validNums.contains);
                print("valid? $valid");
                return valid
                    ? Iterable.empty()
                    : nums.where((num) => !validNums.contains(num));
            })
            .reduce((a, b) => a + b);
    }).then(print);
}

