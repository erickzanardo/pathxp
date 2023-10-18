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
  var _width = 10;
  var _height = 10;
  var _startingPoint = (4, 4);
  var _steps = <(int, int)>[];
  late var _lastStep = _startingPoint;
  PathResult? _parsedPath;

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
        _steps = [];
        _lastStep = _startingPoint;
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

      var point = _startingPoint;
      final newSteps = <(int, int)>[point];

      for (final direction in path.path) {
        switch (direction) {
          case PathDirection.T:
            point = (point.$1, point.$2 - 1);
          case PathDirection.B:
            point = (point.$1, point.$2 + 1);
          case PathDirection.L:
            point = (point.$1 - 1, point.$2);
          case PathDirection.R:
            point = (point.$1 + 1, point.$2);
        }
        newSteps.add(point);
      }

      setState(() {
        _parsedPath = path;
        _steps = newSteps;
        _lastStep = point;
      });
    } catch (_) {
      setState(() {
        _onError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final modifiers = [
      if (_parsedPath?.infinite ?? false) NesIcons.infinite,
      if (_parsedPath?.repeating ?? false) NesIcons.redo,
    ];

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
                  Row(
                    children: [
                      NesContainer(
                        width: 320,
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            NesIconButton(
                              icon: NesIcons.add,
                              onPress: incrementWidth,
                            ),
                            const SizedBox(width: 8),
                            Text('Width: $_width'),
                            const SizedBox(width: 8),
                            NesIconButton(
                              icon: NesIcons.remove,
                              onPress: decrementWidth,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      NesContainer(
                        width: 320,
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            NesIconButton(
                              icon: NesIcons.add,
                              onPress: incrementHeight,
                            ),
                            const SizedBox(width: 8),
                            Text('Height: $_height'),
                            const SizedBox(width: 8),
                            NesIconButton(
                              icon: NesIcons.remove,
                              onPress: decrementHeight,
                            ),
                          ],
                        ),
                      ),
                    ],
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

                      final stepColor =
                          Theme.of(context).textTheme.bodyMedium?.color ??
                              Colors.black;

                      return Stack(
                        children: [
                          Center(
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
                                        child: NesPressable(
                                          onPress: () {
                                            setState(() {
                                              _startingPoint = (x, y);
                                              _lastStep = _startingPoint;
                                              _onChangeExpression();
                                            });
                                          },
                                          child: NesContainer(
                                            width: cellSize,
                                            height: cellSize,
                                            padding: EdgeInsets.zero,
                                            child: (x, y) == _startingPoint
                                                ? Center(
                                                    child: NesIcon(
                                                      size: Size.square(
                                                        cellSize * .6,
                                                      ),
                                                      iconData: NesIcons.flag,
                                                    ),
                                                  )
                                                : (x, y) == _lastStep
                                                    ? Center(
                                                        child: NesIcon(
                                                          size: Size.square(
                                                            cellSize * .6,
                                                          ),
                                                          iconData: NesIcons
                                                              .checkedFlag,
                                                        ),
                                                      )
                                                    : _steps.contains((x, y))
                                                        ? _FilledStep(
                                                            cellSize: cellSize,
                                                            stepColor:
                                                                stepColor,
                                                          )
                                                        : null,
                                          ),
                                        ),
                                      ),
                                ],
                              ),
                            ),
                          ),
                          if (modifiers.isNotEmpty)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Row(
                                children: [
                                  for (final icon in modifiers)
                                    NesIcon(iconData: icon),
                                ],
                              ),
                            ),
                        ],
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

class _FilledStep extends StatelessWidget {
  const _FilledStep({
    super.key,
    required this.cellSize,
    required this.stepColor,
  });

  final double cellSize;
  final Color stepColor;

  @override
  Widget build(BuildContext context) {
    return Align(
      child: SizedBox.square(
        dimension: cellSize * .6,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: stepColor,
          ),
        ),
      ),
    );
  }
}
