import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

class Classifier {
  final String start = '<START>';
  final String pad = '<PAD>';
  final String unk = '<UNKNOWN>';
  late Map<String, int> _dict;
  late tfl.Interpreter _interpreter;

  Future<bool> _loadModel(String modelFile) async {
    // Creating the interpreter using Interpreter.fromAsset
    // print('Interpreter loaded ${_interpreter.isAllocated}');
    _interpreter = await tfl.Interpreter.fromAsset('assets/models/$modelFile');
    // print('Interpreter loaded successfully ${_interpreter.isAllocated}');
    return _interpreter.isAllocated;
  }

  Future<bool> _loadDictionary(String vocabFile) async {
    final vocab = await rootBundle.loadString('assets/models/$vocabFile');
    var dict = <String, int>{};
    final vocabList = vocab.split('\n');
    for (var i = 0; i < vocabList.length; i++) {
      var entry = vocabList[i].trim().split(' ');
      dict[entry[0]] = int.parse(entry[1]);
    }
    _dict = dict;
    // print('Dictionary loaded successfully');
    return _dict.isNotEmpty;
  }

  Future<double?> classify(
      String rawText, String modelFile, String vocabFile, int _sentenceLen) async {
    bool res = await _loadModel(modelFile);
    if (res == true) {
      bool res2 = await _loadDictionary(vocabFile);
      if (res2 == true) {
        List<List<double>> input = tokenizeInputText(rawText,_sentenceLen);
        var output = List<double>.filled(1, 0).reshape([1, 1]);
        _interpreter.run(input, output);
        // print(input);
        return output[0][0];
      }
    }
    return null;
  }

  List<List<double>> tokenizeInputText(String text,int _sentenceLen) {
    // Whitespace tokenization
    final toks = text.split(' ');
    // debugPrint("toks >>>>> $toks");

    // Create a list of length==_sentenceLen filled with the value <pad>
    var vec = List<double>.filled(_sentenceLen, _dict[pad]!.toDouble());

    var index = _sentenceLen - toks.length - 1;
    if (_dict.containsKey(start)) {
      vec[index++] = _dict[start]!.toDouble();
    }

    // For each word in sentence find corresponding index in dict
    for (var tok in toks) {
      if (index >= _sentenceLen) {
        break;
      }
      vec[index++] = _dict.containsKey(tok)
          ? _dict[tok]!.toDouble()
          : _dict[unk]!.toDouble();
    }

    // returning List<List<double>> as our interpreter input tensor expects the shape, [1,256]
    return [vec];
  }
}
