part of graph_renderer;

abstract class Algorithm {
  @nonVirtual
  @protected
  void call(Graph graph, Node? focusNode, Size size) {
    layout(graph, focusNode, size);
    _translate(graph, size);
  }

  _translate(Graph graph, Size size) {
    for (final node in graph) {
      node.position.translate(size.width, size.height);
    }
  }

  void layout(Graph graph, Node? focusNode, Size size);
}
