// ignore_for_file: public_member_api_docs
import 'package:flutter/material.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:pathxp/pathxp.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: flutterNesTheme(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final _expressionController = TextEditingController();

  bool _onError = false;
  var _path = <PathDirection>[];
  var _width = 10;
  var _height = 10;

  @override
  void dispose() {
    _expressionController.dispose();
    super.dispose();
  }

  void incrementWidth() {
    setState(() {
      _width++;
    });
  }

  void decrementWidth() {
    if (_width <= 1) {
      return;
    }
    setState(() {
      _width--;
    });
  }

  void incrementHeight() {
    setState(() {
      _height++;
    });
  }

  void decrementHeight() {
    if (_height <= 1) {
      return;
    }
    setState(() {
      _height--;
    });
  }

  void _onChangeExpression() {
    if (_expressionController.text.isEmpty) {
      setState(() {
        _path = [];
      });
      return;
    }

    final expression = _expressionController.text;

    try {
      final pathXp = Pathxp(expression);

      setState(() {
        _onError = false;
      });

      final path = pathXp.path;
      setState(() {
        _path = path;
      });
    } catch (_) {
      setState(() {
        _onError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            NesContainer(
              label: 'Expression',
              child: Column(
                children: [
                  TextFormField(
                    controller: _expressionController,
                    onChanged: (_) => _onChangeExpression(),
                    decoration: InputDecoration(
                      errorText: _onError ? 'Invalid expression' : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  NesContainer(
                    width: 320,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        NesIconButton(
                          icon: NesIcons.instance.add,
                          onPress: incrementWidth,
                        ),
                        const SizedBox(width: 8),
                        Text('Width: $_width'),
                        const SizedBox(width: 8),
                        NesIconButton(
                          icon: NesIcons.instance.remove,
                          onPress: decrementWidth,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  NesContainer(
                    width: 320,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        NesIconButton(
                          icon: NesIcons.instance.add,
                          onPress: incrementHeight,
                        ),
                        const SizedBox(width: 8),
                        Text('Height: $_height'),
                        const SizedBox(width: 8),
                        NesIconButton(
                          icon: NesIcons.instance.remove,
                          onPress: decrementHeight,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: NesContainer(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cellSize =
                          constraints.maxWidth < constraints.maxHeight
                              ? constraints.maxWidth / _width
                              : constraints.maxHeight / _height;

                      final cellColor =
                          Theme.of(context).textTheme.bodyMedium?.color ??
                              Colors.black;

                      return Center(
                        child: SizedBox(
                          width: _width * cellSize,
                          height: _height * cellSize,
                          child: Stack(
                            children: [
                              for (var y = 0; y < _height; y++)
                                for (var x = 0; x < _width; x++)
                                  Positioned(
                                    left: x * cellSize,
                                    top: y * cellSize,
                                    width: cellSize,
                                    height: cellSize,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: cellColor,
                                        ),
                                      ),
                                    ),
                                  ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
