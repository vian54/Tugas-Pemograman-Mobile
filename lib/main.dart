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

  String get display => _display;
  String get equation => _equation;

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

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;
  bool _isMenuOpen = false;
  String _lastPressedButton = '';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  void _onButtonPressed(String button) {
    setState(() {
      _lastPressedButton = button;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _lastPressedButton = '';
        });
      }
    });
  }

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
          GestureDetector(
            onTap: _toggleMenu,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _isMenuOpen ? const Color(0xFF505050) : const Color(0xFF333333),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isMenuOpen ? Icons.close : Icons.list,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calculate_outlined, color: Colors.white, size: 24),
            ),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: calc.equation.isEmpty ? 0.0 : 0.7,
                child: Text(
                  calc.equation,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Color(0xFF00F0FF),
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                calc.display,
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          // Row 1 - 6 buttons
          _buildButtonRow([
            ('(', ButtonType.dark, 1),
            (')', ButtonType.dark, 1),
            ('mc', ButtonType.dark, 1),
            ('m+', ButtonType.dark, 1),
            ('m-', ButtonType.dark, 1),
            ('mr', ButtonType.dark, 1),
          ], smallButton: true),
          // Row 2
          _buildButtonRow([
            ('2ⁿᵈ', ButtonType.dark, 1),
            ('x²', ButtonType.dark, 1),
            ('x³', ButtonType.dark, 1),
            ('xʸ', ButtonType.dark, 1),
            ('eˣ', ButtonType.dark, 1),
            ('10ˣ', ButtonType.dark, 1),
          ], smallButton: true),
          // Row 3
          _buildButtonRow([
            ('1/x', ButtonType.dark, 1),
            ('√', ButtonType.dark, 1),
            ('∛', ButtonType.dark, 1),
            ('ʸ√x', ButtonType.dark, 1),
            ('ln', ButtonType.dark, 1),
            ('log', ButtonType.dark, 1),
          ], smallButton: true),
          // Row 4
          _buildButtonRow([
            ('x!', ButtonType.dark, 1),
            ('sin', ButtonType.dark, 1),
            ('cos', ButtonType.dark, 1),
            ('tan', ButtonType.dark, 1),
            ('e', ButtonType.dark, 1),
            ('EE', ButtonType.dark, 1),
          ], smallButton: true),
          // Row 5
          _buildButtonRow([
            ('Rand', ButtonType.dark, 1),
            ('sinh', ButtonType.dark, 1),
            ('cosh', ButtonType.dark, 1),
            ('tanh', ButtonType.dark, 1),
            ('π', ButtonType.dark, 1),
            ('Rad', ButtonType.dark, 1),
          ], smallButton: true),
          // Row 6 - Special row dengan backspace lebar
          SizedBox(
            height: 52,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildSingleButton('⌫', ButtonType.light),
                ),
                Expanded(child: _buildSingleButton('C', ButtonType.light)),
                Expanded(child: _buildSingleButton('%', ButtonType.light)),
                Expanded(child: _buildSingleButton('÷', ButtonType.orange)),
              ],
            ),
          ),
          // Row 7-10 - 4 buttons each
          _buildButtonRow([
            ('7', ButtonType.number, 1),
            ('8', ButtonType.number, 1),
            ('9', ButtonType.number, 1),
            ('×', ButtonType.orange, 1),
          ]),
          _buildButtonRow([
            ('4', ButtonType.number, 1),
            ('5', ButtonType.number, 1),
            ('6', ButtonType.number, 1),
            ('-', ButtonType.orange, 1),
          ]),
          _buildButtonRow([
            ('1', ButtonType.number, 1),
            ('2', ButtonType.number, 1),
            ('3', ButtonType.number, 1),
            ('+', ButtonType.orange, 1),
          ]),
          _buildButtonRow([
            ('+/-', ButtonType.number, 1),
            ('0', ButtonType.number, 1),
            ('.', ButtonType.number, 1),
            ('=', ButtonType.orange, 1),
          ]),
        ],
      ),
    );
  }

  Widget _buildButtonRow(List<(String, ButtonType, int)> buttons, {bool smallButton = false}) {
    return SizedBox(
      height: smallButton ? 42 : 52,
      child: Row(
        children: buttons.map((btn) {
          return Expanded(
            flex: btn.$3,
            child: _buildSingleButton(btn.$1, btn.$2, smallButton: smallButton),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSingleButton(String text, ButtonType type, {bool smallButton = false}) {
    Color bgColor;
    Color textColor = Colors.white;
    double fontSize = smallButton ? 16 : 26;

    switch (type) {
      case ButtonType.orange:
        bgColor = const Color(0xFFFF9500);
        fontSize = smallButton ? 24 : 32;
        break;
      case ButtonType.light:
        bgColor = const Color(0xFFA6A6A6);
        textColor = Colors.black;
        fontSize = smallButton ? 20 : 26;
        break;
      case ButtonType.dark:
        bgColor = const Color(0xFF333333);
        fontSize = smallButton ? 16 : 20;
        break;
      case ButtonType.number:
        bgColor = const Color(0xFF505050);
        fontSize = smallButton ? 24 : 32;
        break;
    }

    final isPressed = _lastPressedButton == text;

    return Container(
      margin: EdgeInsets.all(smallButton ? 2 : 3),
      child: AnimatedScale(
        scale: isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(smallButton ? 18 : 22),
          child: InkWell(
            onTap: () {
              _onButtonPressed(text);
              _handleButtonPress(text);
            },
            borderRadius: BorderRadius.circular(smallButton ? 18 : 22),
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

  void _handleButtonPress(String text) {
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