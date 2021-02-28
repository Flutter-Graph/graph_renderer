part of graph_renderer;

class GraphNode extends LeafRenderObjectWidget {
  final String id;
  final double nodeRadius;
  final String label;
  final TextStyle labelStyle;
  final Color color;
  final Color activeColor;
  final Color hoverColor;
  final bool labelVisible;
  final bool active;
  final bool hover;

  const GraphNode({
    Key? key,
    required this.id,
    required this.nodeRadius,
    required this.label,
    required this.labelStyle,
    required this.color,
    required this.activeColor,
    required this.hoverColor,
    required this.labelVisible,
    required this.active,
    required this.hover,
  }): super(key: key);

  @override
  RenderGraphNode createRenderObject(BuildContext context) {
    return RenderGraphNode(
      id: id,
      nodeRadius:  nodeRadius,
      label: label,
      labelStyle: labelStyle,
      color: color,
      activeColor: activeColor,
      hoverColor: hoverColor,
      labelVisible: labelVisible,
      active: active,
      hover: hover,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderGraphNode renderObject) {
    renderObject
      ..id = id
      ..nodeRadius = nodeRadius
      ..label = label
      ..labelStyle = labelStyle
      ..color = color
      ..activeColor = activeColor
      ..hoverColor = hoverColor
      ..labelVisible = labelVisible
      ..active = active
      ..hover = hover;
  }
}
