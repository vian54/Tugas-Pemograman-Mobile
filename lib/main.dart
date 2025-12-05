import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CalculatorProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iOS Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorProvider extends ChangeNotifier {
  String _display = '0';
  String _equation = '';
  double _firstNum = 0;
  String _operator = '';
  bool _shouldResetDisplay = false;
  bool _isScientific = true;

  String get display => _display;
  String get equation => _equation;
  bool get isScientific => _isScientific;

  void toggleMode() {
    _isScientific = !_isScientific;
    notifyListeners();
  }

  void inputNumber(String num) {
    if (_shouldResetDisplay) {
      _display = num;
      _shouldResetDisplay = false;
    } else {
      _display = _display == '0' ? num : _display + num;
    }
    notifyListeners();
  }

  void inputDecimal() {
    if (!_display.contains('.')) {
      _display += '.';
      notifyListeners();
    }
  }

  void setOperator(String op) {
    _firstNum = double.parse(_display);
    _operator = op;
    _equation = '$_display $op';
    _shouldResetDisplay = true;
    notifyListeners();
  }

  void calculate() {
    if (_operator.isEmpty) return;

    double secondNum = double.parse(_display);
    double result = 0;

    switch (_operator) {
      case '+':
        result = _firstNum + secondNum;
        break;
      case '-':
        result = _firstNum - secondNum;
        break;
      case '×':
        result = _firstNum * secondNum;
        break;
      case '÷':
        result = secondNum != 0 ? _firstNum / secondNum : 0;
        break;
    }

    _display = _formatResult(result);
    _operator = '';
    _shouldResetDisplay = true;
    notifyListeners();
  }

  void scientificFunction(String func) {
    double num = double.parse(_display);
    double result = 0;

    switch (func) {
      case 'sin':
        result = math.sin(num);
        break;
      case 'cos':
        result = math.cos(num);
        break;
      case 'tan':
        result = math.tan(num);
        break;
      case 'ln':
        result = math.log(num);
        break;
      case 'log':
        result = math.log(num) / math.log(10);
        break;
      case 'x²':
        result = num * num;
        break;
      case 'x³':
        result = num * num * num;
        break;
      case '√':
        result = math.sqrt(num);
        break;
      case 'x!':
        result = _factorial(num.toInt()).toDouble();
        break;
      case 'e':
        result = math.e;
        break;
      case 'π':
        result = math.pi;
        break;
      case '1/x':
        result = 1 / num;
        break;
      case 'eˣ':
        result = math.exp(num);
        break;
      case '10ˣ':
        result = math.pow(10, num).toDouble();
        break;
    }

    _display = _formatResult(result);
    _shouldResetDisplay = true;
    notifyListeners();
  }

  int _factorial(int n) {
    if (n <= 1) return 1;
    return n * _factorial(n - 1);
  }

  String _formatResult(double result) {
    if (result == result.toInt()) {
      return result.toInt().toString();
    }
    return result.toStringAsFixed(8).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  void clear() {
    _display = '0';
    _equation = '';
    _firstNum = 0;
    _operator = '';
    _shouldResetDisplay = false;
    notifyListeners();
  }

  void toggleSign() {
    if (_display != '0') {
      if (_display.startsWith('-')) {
        _display = _display.substring(1);
      } else {
        _display = '-$_display';
      }
      notifyListeners();
    }
  }

  void percentage() {
    double num = double.parse(_display);
    _display = _formatResult(num / 100);
    notifyListeners();
  }

  void backspace() {
    if (_display.length > 1) {
      _display = _display.substring(0, _display.length - 1);
    } else {
      _display = '0';
    }
    notifyListeners();
  }
}

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(child: _buildDisplay()),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF333333),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.list, color: Colors.white, size: 24),
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF333333),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.calculate_outlined, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplay() {
    return Consumer<CalculatorProvider>(
      builder: (context, calc, child) {
        return Container(
          padding: const EdgeInsets.all(32),
          alignment: Alignment.bottomRight,
          child: Text(
            calc.display,
            style: const TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }

  Widget _buildButtons() {
    return Consumer<CalculatorProvider>(
      builder: (context, calc, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Row 1: Scientific functions
              Row(
                children: [
                  _buildButton(context, '(', type: ButtonType.dark),
                  _buildButton(context, ')', type: ButtonType.dark),
                  _buildButton(context, 'mc', type: ButtonType.dark),
                  _buildButton(context, 'm+', type: ButtonType.dark),
                  _buildButton(context, 'm-', type: ButtonType.dark),
                  _buildButton(context, 'mr', type: ButtonType.dark),
                ],
              ),
              // Row 2
              Row(
                children: [
                  _buildButton(context, '2ⁿᵈ', type: ButtonType.dark),
                  _buildButton(context, 'x²', type: ButtonType.dark),
                  _buildButton(context, 'x³', type: ButtonType.dark),
                  _buildButton(context, 'xʸ', type: ButtonType.dark),
                  _buildButton(context, 'eˣ', type: ButtonType.dark),
                  _buildButton(context, '10ˣ', type: ButtonType.dark),
                ],
              ),
              // Row 3
              Row(
                children: [
                  _buildButton(context, '1/x', type: ButtonType.dark),
                  _buildButton(context, '√', type: ButtonType.dark),
                  _buildButton(context, '∛', type: ButtonType.dark),
                  _buildButton(context, 'ʸ√x', type: ButtonType.dark),
                  _buildButton(context, 'ln', type: ButtonType.dark),
                  _buildButton(context, 'log', type: ButtonType.dark),
                ],
              ),
              // Row 4
              Row(
                children: [
                  _buildButton(context, 'x!', type: ButtonType.dark),
                  _buildButton(context, 'sin', type: ButtonType.dark),
                  _buildButton(context, 'cos', type: ButtonType.dark),
                  _buildButton(context, 'tan', type: ButtonType.dark),
                  _buildButton(context, 'e', type: ButtonType.dark),
                  _buildButton(context, 'EE', type: ButtonType.dark),
                ],
              ),
              // Row 5
              Row(
                children: [
                  _buildButton(context, 'Rand', type: ButtonType.dark),
                  _buildButton(context, 'sinh', type: ButtonType.dark),
                  _buildButton(context, 'cosh', type: ButtonType.dark),
                  _buildButton(context, 'tanh', type: ButtonType.dark),
                  _buildButton(context, 'π', type: ButtonType.dark),
                  _buildButton(context, 'Rad', type: ButtonType.dark),
                ],
              ),
              // Row 6
              Row(
                children: [
                  _buildButton(context, '⌫', type: ButtonType.light, flex: 2),
                  _buildButton(context, 'C', type: ButtonType.light),
                  _buildButton(context, '%', type: ButtonType.light),
                  _buildButton(context, '÷', type: ButtonType.orange),
                ],
              ),
              // Row 7
              Row(
                children: [
                  _buildButton(context, '7', type: ButtonType.number),
                  _buildButton(context, '8', type: ButtonType.number),
                  _buildButton(context, '9', type: ButtonType.number),
                  _buildButton(context, '×', type: ButtonType.orange),
                ],
              ),
              // Row 8
              Row(
                children: [
                  _buildButton(context, '4', type: ButtonType.number),
                  _buildButton(context, '5', type: ButtonType.number),
                  _buildButton(context, '6', type: ButtonType.number),
                  _buildButton(context, '-', type: ButtonType.orange),
                ],
              ),
              // Row 9
              Row(
                children: [
                  _buildButton(context, '1', type: ButtonType.number),
                  _buildButton(context, '2', type: ButtonType.number),
                  _buildButton(context, '3', type: ButtonType.number),
                  _buildButton(context, '+', type: ButtonType.orange),
                ],
              ),
              // Row 10
              Row(
                children: [
                  _buildButton(context, '+/-', type: ButtonType.number),
                  _buildButton(context, '0', type: ButtonType.number),
                  _buildButton(context, '.', type: ButtonType.number),
                  _buildButton(context, '=', type: ButtonType.orange),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildButton(
    BuildContext context,
    String text, {
    required ButtonType type,
    int flex = 1,
  }) {
    Color bgColor;
    Color textColor = Colors.white;
    double fontSize = 22;

    switch (type) {
      case ButtonType.orange:
        bgColor = const Color(0xFFFF9500);
        fontSize = 32;
        break;
      case ButtonType.light:
        bgColor = const Color(0xFFA6A6A6);
        textColor = Colors.black;
        fontSize = 28;
        break;
      case ButtonType.dark:
        bgColor = const Color(0xFF333333);
        fontSize = 18;
        break;
      case ButtonType.number:
        bgColor = const Color(0xFF505050);
        fontSize = 32;
        break;
    }

    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.all(4),
        height: 50,
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(25),
          child: InkWell(
            onTap: () => _handleButtonPress(context, text),
            borderRadius: BorderRadius.circular(25),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  color: textColor,
                  fontWeight: type == ButtonType.number || type == ButtonType.orange
                      ? FontWeight.w400
                      : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleButtonPress(BuildContext context, String text) {
    final calc = Provider.of<CalculatorProvider>(context, listen: false);

    if (text == 'C') {
      calc.clear();
    } else if (text == '⌫') {
      calc.backspace();
    } else if (text == '=') {
      calc.calculate();
    } else if (['+', '-', '×', '÷'].contains(text)) {
      calc.setOperator(text);
    } else if (text == '.') {
      calc.inputDecimal();
    } else if (text == '+/-') {
      calc.toggleSign();
    } else if (text == '%') {
      calc.percentage();
    } else if (['sin', 'cos', 'tan', 'ln', 'log', 'x²', 'x³', '√', 'x!', 'e', 'π', '1/x', 'eˣ', '10ˣ'].contains(text)) {
      calc.scientificFunction(text);
    } else if (RegExp(r'^\d$').hasMatch(text)) {
      calc.inputNumber(text);
    }
  }
}

enum ButtonType {
  orange,
  light,
  dark,
  number,
}