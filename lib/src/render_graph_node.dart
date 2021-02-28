part of graph_renderer;

class RenderGraphNode extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  static const double nodeLabelSpacing = 10;

  RenderGraphNode({
    required String id,
    required String label,
    required TextStyle labelStyle,
    required double nodeRadius,
    required Color color,
    required Color activeColor,
    required Color hoverColor,
    required bool labelVisible,
    required bool active,
    required bool hover,
  })   : _id = id,
        _label = label,
        _labelStyle = labelStyle,
        _nodeRadius = nodeRadius,
        _color = color,
        _activeColor = activeColor,
        _hoverColor = hoverColor,
        _labelVisible = labelVisible,
        _active = active,
        _hover = hover {
    child = RenderParagraph(TextSpan(text: label, style: labelStyle),
        textDirection: TextDirection.ltr);
  }

  String get id => _id;
  String _id;

  set id(String value) {
    if (id == value) {
      return;
    }
    id = value;
  }

  String get label => _label;
  String _label;

  set label(String value) {
    if (label == value) {
      return;
    }
    _label = value;
    _setChild(text: label);
  }

  Color get color => _color;
  Color _color;

  set color(Color value) {
    if (color == value) {
      return;
    }
    _color = value;

    if (!hover && !active) {
      markNeedsPaint();
    }
  }

  Color get activeColor => _activeColor;
  Color _activeColor;

  set activeColor(Color value) {
    if (activeColor == value) {
      return;
    }
    _activeColor = value;
    if (active && !hover) {
      markNeedsPaint();
    }
  }

  Color get hoverColor => _hoverColor;
  Color _hoverColor;

  set hoverColor(Color value) {
    if (hoverColor == value) {
      return;
    }
    _hoverColor = value;
    if (hover) {
      markNeedsPaint();
    }
  }

  bool get labelVisible => _labelVisible;
  bool _labelVisible;

  set labelVisible(bool value) {
    if (labelVisible == value) {
      return;
    }
    _labelVisible = value;
    markNeedsPaint();
  }

  bool get active => _active;
  bool _active;

  set active(bool value) {
    if (active == value) {
      return;
    }
    _active = value;
    markNeedsPaint();
  }

  bool get hover => _hover;
  bool _hover;

  set hover(bool value) {
    if (hover == value) {
      return;
    }
    _hover = value;
    markNeedsPaint();
  }

  double get nodeRadius => _nodeRadius;
  double _nodeRadius;

  set nodeRadius(double value) {
    if (nodeRadius == value) {
      return;
    }
    _nodeRadius = value;
    markNeedsLayout();
  }

  TextStyle get labelStyle => _labelStyle;
  TextStyle _labelStyle;

  set labelStyle(TextStyle value) {
    if (labelStyle == value) {
      return;
    }
    _labelStyle = value;
    _setChild(style: labelStyle);
  }

  _setChild({String? text, TextStyle? style}) {
    text ??= label;
    style ??= labelStyle;

    child = RenderParagraph(TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr);
    markNeedsLayout();
  }

  @override
  Size getDryLayout(BoxConstraints constraints) {
    super.getDryLayout(constraints);

    final childSize = child!.computeDryLayout(constraints);

    final width = max(childSize.width, nodeRadius);
    final height = childSize.height + nodeRadius + nodeLabelSpacing;

    return Size(width, height);
  }

  @override
  void performLayout() {
    child!.layout(constraints, parentUsesSize: true);
    final childSize = child!.size;

    final width = max(childSize.width, nodeRadius);
    final height = childSize.height + nodeRadius + nodeLabelSpacing;

    final parentData = child!.parentData as BoxParentData;
    parentData.offset =
        Offset((width - childSize.width) / 2, nodeRadius + nodeLabelSpacing);

    size = Size(width, height);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final paint = Paint()..color = _getCurrentColor();
    context.canvas.drawCircle(
        offset + Offset(size.width / 2, nodeRadius), nodeRadius, paint);

    if (labelVisible) {
      final parentData = child!.parentData as BoxParentData;
      context.paintChild(child!, offset + parentData.offset);
    }
  }

  Color _getCurrentColor() {
    if (hover) {
      return hoverColor;
    }
    if (active) {
      return activeColor;
    }
    return color;
  }
}
