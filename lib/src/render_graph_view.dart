part of graph_renderer;

class RenderGraphView extends RenderBox
    with ContainerRenderObjectMixin<RenderGraphNode, GraphViewportParentData> {
  static const double PADDING = 20;

  RenderGraphView({
    required Graph graph,
    required Algorithm algorithm,
    required Color backgroundColor,
    Node? focusNode,
    EdgeRenderer edgeRenderer = const DefaultEdgeRenderer(),
  })  : assert(graph.has(focusNode),
            ' The passed focusNode is not a node of the passed Graph'),
        _graph = graph,
        _algorithm = algorithm,
        _backgroundColor = backgroundColor,
        _edgeRenderer = edgeRenderer,
        _focusNode = focusNode;

  Graph get graph => _graph;
  Graph _graph;

  set graph(Graph value) {
    if (graph == value) {
      return;
    }
    _graph = value;
    markNeedsLayout();
  }

  Algorithm get algorithm => _algorithm;
  Algorithm _algorithm;

  set algorithm(Algorithm value) {
    if (algorithm == value) {
      return;
    }
    _algorithm = value;
    markNeedsLayout();
  }

  Color get backgroundColor => _backgroundColor;
  Color _backgroundColor;

  set backgroundColor(Color value) {
    if (backgroundColor == value) {
      return;
    }
    _backgroundColor = value;
    markNeedsPaint();
  }

  EdgeRenderer get edgeRenderer => _edgeRenderer;
  EdgeRenderer _edgeRenderer;

  set edgeRenderer(EdgeRenderer value) {
    if (edgeRenderer == value) {
      return;
    }
    _edgeRenderer = value;
    markNeedsLayout();
  }

  Node? get focusNode => _focusNode;
  Node? _focusNode;

  set focusNode(Node? value) {
    if (focusNode == value) {
      return;
    }
    assert(graph.has(focusNode),
        ' The passed focusNode is not a node of the passed Graph');
    _focusNode = value;
    markNeedsLayout();
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    assert(constraints.hasBoundedHeight && constraints.hasBoundedWidth,
        'A GraphViewport was given unbound height or width');
    return constraints.biggest;
  }

  @override
  void performLayout() {
    size = computeDryLayout(constraints);

    RenderGraphNode? child = firstChild;
    while (child != null) {
      final parentData = child.parentData as GraphViewportParentData;

      child.layout(constraints.loosen(), parentUsesSize: true);
      final id = child.id;
      final node = graph.get(id);
      node.size = child.size;
      graph.update(node);

      child = parentData.nextSibling as RenderGraphNode;
    }

    algorithm(
        graph, focusNode, Size(size.width - PADDING, size.height - PADDING));

    child = firstChild;
    while (child != null) {
      final parentData = child.parentData as GraphViewportParentData;
      final id = child.id;
      final node = graph.get(id);

      parentData.offset = node.position;

      child = parentData.nextSibling as RenderGraphNode;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.drawRect(offset & size, Paint()..color = backgroundColor);

    RenderGraphNode? child = firstChild;
    while (child != null) {
      final parentData = child.parentData as GraphViewportParentData;

      context.paintChild(
          child, parentData.offset + Offset(PADDING / 2, PADDING / 2));

      child = parentData.nextSibling as RenderGraphNode;
    }

    edgeRenderer(graph, context, offset);
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! GraphViewportParentData) {
      child.parentData = GraphViewportParentData();
    }
  }
}

class GraphViewportParentData extends ContainerBoxParentData<RenderGraphNode> {}
