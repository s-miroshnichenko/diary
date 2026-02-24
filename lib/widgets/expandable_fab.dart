import 'dart:math' as math;
import 'package:flutter/material.dart';

class ExpandableFab extends StatefulWidget {
  final double distance;
  final List<Widget> children;
  final ValueChanged<bool>? onToggle;

  const ExpandableFab({
    Key? key,
    required this.distance,
    required this.children,
    this.onToggle,
  }) : super(key: key);

  @override
  State<ExpandableFab> createState() => ExpandableFabState();
}

class ExpandableFabState extends State<ExpandableFab> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200), // Чуть ускорили анимацию
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      if (widget.onToggle != null) {
        widget.onToggle!(_open);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.distance * 2 + 56,
      height: widget.distance + 56,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56,
      height: 56,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          color: Colors.white,
          child: InkWell(
            onTap: toggle,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.close,
                color: Colors.indigo,
                size: 30, // Сделали крестик чуть крупнее
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 200),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 200),
          child: FloatingActionButton(
            backgroundColor: Colors.indigo,
            onPressed: toggle,
            elevation: 4,
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
      ),
    );
  }

    List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    
    final anglesInDegrees = [-155.0, -90.0, -25.0];
    final distances = [
      widget.distance * 1.3, 
      widget.distance * 1.1, 
      widget.distance * 1.3, 
    ];

    for (var i = 0; i < widget.children.length; i++) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: anglesInDegrees[i],
          maxDistance: distances[i], 
          baseDistance: widget.distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }
}

class _ExpandingActionButton extends StatelessWidget {
  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;
  final double baseDistance; // 1. Добавляем базовую дистанцию

  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
    required this.baseDistance, // 2. Требуем ее в конструкторе
  });

    @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );

        return Positioned(
          // 1. Устанавливаем координату X ровно в центр крестика
          left: (baseDistance + 28) + offset.dx, 
          
          // 2. Устанавливаем координату Y в центр крестика (28) 
          // и вычитаем 46 — точное расстояние от низа ActionButton до центра её иконки
          bottom: 28 - offset.dy - 46, 
          
          // 3. Сдвигаем виджет влево ровно на 50% ЕГО ширины.
          // Это гарантирует идеальное центрирование по X даже для длинных текстов!
          child: FractionalTranslation(
            translation: const Offset(-0.5, 0.0), 
            child: child!,
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}


class ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final String? topLabel; // Добавили опциональный текст сверху

  const ActionButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.topLabel, // Добавили в конструктор
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Если передан верхний текст — показываем его
        if (topLabel != null) ...[
          Text(
            topLabel!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12), // Отступ до самой кнопки
        ],
        Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          color: Colors.white,
          elevation: 4,
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Icon(icon, color: Colors.indigo, size: 24),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white, 
            fontSize: 11, 
            fontWeight: FontWeight.w400
          ),
        )
      ],
    );
  }
}
