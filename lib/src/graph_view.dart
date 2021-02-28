part of graph_renderer;

class GraphView extends StatefulWidget {
  final Graph graph;
  final Algorithm algorithm;
  final Color backgroundColor;
  final double nodeRadius;
  final TextStyle labelStyle;
  final Color nodeColor;
  final Color nodeActiveColor;
  final Color nodeHoverColor;
  final bool? nodeLabelVisible;

  GraphView(
      {Key? key,
      required this.graph,
      required this.algorithm,
      this.backgroundColor = const Color(0xFFFFFFFF),
      this.nodeRadius = 15,
      this.labelStyle = const TextStyle(color: Color(0xFF000000)),
      this.nodeColor = const Color(0x71000000),
      this.nodeActiveColor = const Color(0xFF000000),
      this.nodeHoverColor = const Color(0x91000000),
      this.nodeLabelVisible})
      : super(key: key);

  @override
  _GraphViewState createState() => _GraphViewState();
}

class _GraphViewState extends State<GraphView> {
  @override
  Widget build(BuildContext context) {
    final List<GraphNode> nodes = widget.graph
        .map(
          (e) => GraphNode(
            key: Key(e.id),
            id: e.id,
            nodeRadius: widget.nodeRadius,
            label: e.label,
            labelStyle: widget.labelStyle,
            color: widget.nodeColor,
            activeColor: widget.nodeActiveColor,
            hoverColor: widget.nodeHoverColor,
            labelVisible: widget.nodeLabelVisible ?? true,
            active: false,
            hover: false,
          ),
        )
        .toList();

    return GraphViewport(
      graph: widget.graph,
      algorithm: widget.algorithm,
      backgroundColor: widget.backgroundColor,
      nodes: nodes,
    );
  }
}
