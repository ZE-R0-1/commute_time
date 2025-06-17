import 'package:flutter/material.dart';

class PingPongText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final double? height;
  final Duration animationDuration;
  final Duration pauseDuration;
  final bool enabled;

  const PingPongText({
    super.key,
    required this.text,
    this.style,
    this.height,
    this.animationDuration = const Duration(seconds: 3),
    this.pauseDuration = const Duration(seconds: 2),
    this.enabled = true,
  });

  @override
  State<PingPongText> createState() => _PingPongTextState();
}

class _PingPongTextState extends State<PingPongText>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _textWidth = 0;
  double _containerWidth = 0;
  bool _needsAnimation = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // 애니메이션 완료 시 반대 방향으로 실행
    _animationController.addStatusListener(_onAnimationStatusChanged);
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (!mounted || !widget.enabled) return;

    switch (status) {
      case AnimationStatus.completed:
      // 왼쪽 끝에 도달했을 때 - 잠시 멈춤 후 오른쪽으로
        Future.delayed(widget.pauseDuration, () {
          if (mounted && _needsAnimation) {
            _animationController.reverse();
          }
        });
        break;
      case AnimationStatus.dismissed:
      // 오른쪽 끝에 도달했을 때 - 잠시 멈춤 후 왼쪽으로
        Future.delayed(widget.pauseDuration, () {
          if (mounted && _needsAnimation) {
            _animationController.forward();
          }
        });
        break;
      default:
        break;
    }
  }

  void _calculateTextWidth() {
    if (!mounted) return;

    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    _textWidth = textPainter.width;

    // 텍스트가 컨테이너보다 크면 애니메이션 필요
    _needsAnimation = _textWidth > _containerWidth && _containerWidth > 0;

    if (_needsAnimation && widget.enabled) {
      // 애니메이션 시작
      _animationController.forward();
    } else {
      // 애니메이션 중지
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  void didUpdateWidget(PingPongText oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 텍스트가 변경되면 다시 계산
    if (oldWidget.text != widget.text ||
        oldWidget.style != widget.style ||
        oldWidget.enabled != widget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _calculateTextWidth();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _containerWidth = constraints.maxWidth;

        // 첫 렌더링 후 텍스트 너비 계산
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _calculateTextWidth();
        });

        return SizedBox(
          height: widget.height ??
              (widget.style?.fontSize ?? 14) *
                  (widget.style?.height ?? 1.2),
          width: double.infinity,
          child: ClipRect(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                // 애니메이션이 필요 없으면 그냥 텍스트 표시
                if (!_needsAnimation || !widget.enabled) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.text,
                      style: widget.style,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }

                // 왕복 스크롤 계산
                final maxOffset = _textWidth - _containerWidth;
                final offset = -maxOffset * _animation.value;

                return Transform.translate(
                  offset: Offset(offset, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.text,
                      style: widget.style,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

/// 간편 사용을 위한 헬퍼 함수
class TextAnimationHelper {
  /// 텍스트 길이를 기준으로 애니메이션 여부 결정
  static Widget buildAutoText(
      String text, {
        TextStyle? style,
        double? height,
        int maxLength = 15,
        Duration animationDuration = const Duration(seconds: 3),
        Duration pauseDuration = const Duration(seconds: 2),
      }) {
    // 텍스트가 짧으면 일반 텍스트
    if (text.length <= maxLength) {
      return Text(
        text,
        style: style,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    }

    // 텍스트가 길면 왕복 스크롤
    return PingPongText(
      text: text,
      style: style,
      height: height,
      animationDuration: animationDuration,
      pauseDuration: pauseDuration,
    );
  }
}