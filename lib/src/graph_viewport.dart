part of graph_renderer;

class GraphViewport extends MultiChildRenderObjectWidget {
  final Graph graph;
  final Algorithm algorithm;
  final Color backgroundColor;

  GraphViewport(
      {required this.graph,
      required this.algorithm,
      required this.backgroundColor,
      Key? key,
      List<GraphNode> nodes = const []})
      : super(key: key, children: nodes);

  @override
  RenderGraphView createRenderObject(BuildContext context) {
    return RenderGraphView(
      graph: graph,
      algorithm: algorithm,
      backgroundColor: backgroundColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderGraphView renderObject) {
    renderObject
      ..graph = graph
      ..algorithm = algorithm..backgroundColor = backgroundColor;
  }
}
