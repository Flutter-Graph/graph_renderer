part of graph_renderer;

class FruchtermanReingoldAlgorithm extends Algorithm {
  static const int DEFAULT_ITERATIONS = 1000;
  static const int CLUSTER_PADDING = 15;
  static const double EPSILON = 0.0001;

  final Map<String, Offset> displacement = {};
  late Graph graph;
  late Node? focusNode;
  late Size size;
  late double tick;
  late double k;

  double get attractionK => 0.75 * k;

  double get repulsionK => 0.75 * k;

  double get width => size.width;

  double get height => size.height;

  @override
  void layout(Graph graph, Node? focusNode, Size size) {
    this.graph = graph;
    this.size = size;
    tick = 0.1 * sqrt(width / 2 * height / 2);
    k = 0.75 * sqrt(width * height / graph.length);

    init(graph, size);

    for (var i = 0; i < DEFAULT_ITERATIONS; i++) {
      calculateRepulsion();

      calculateAttraction();

      limitMaximumDisplacement();

      cool(i);

      if (done()) {
        break;
      }
    }

    if (focusNode == null) {
      positionNodes();
    }

    displacement.clear();
  }

  void init(Graph graph, Size size) {
    final random = Random();
    for (final node in graph) {
      displacement[node.id] = Offset.zero;
      if (node.position.distance == 0.0) {
        node.position = Offset(
            randInt(random, 0, size.width), randInt(random, 0, size.height));
      }
    }
  }

  double forceAttraction(double x) => x * x / attractionK;

  double forceRepulsion(double x) => repulsionK * repulsionK / x;

  void calculateRepulsion() {
    for (final v in graph.items) {
      for (final u in graph.items) {
        if (u != v) {
          var delta = v.position - u.position;
          var deltaLength = max(EPSILON, delta.distance);

          displacement[v.id] = (displacement[v.id]! +
              (delta / deltaLength * forceRepulsion(deltaLength)));
        }
      }
    }
  }

  void calculateAttraction() {
    for (final edge in graph.links()) {
      var source = edge.source;
      var target = edge.target;

      var delta = source.position - target.position;
      var deltaLength = max(EPSILON, delta.distance);
      var offsetDis = delta / deltaLength * forceAttraction(deltaLength);

      displacement[source.id] = (displacement[source.id]! - offsetDis);
      displacement[target.id] = (displacement[target.id]! + offsetDis);
    }
  }

  void limitMaximumDisplacement() {
    for (final node in graph) {
      if (node != focusNode) {
        var disLength = max(EPSILON, displacement[node]!.distance);
        node.position += displacement[node]! / disLength * min(disLength, tick);
      } else {
        displacement[node.id] = Offset.zero;
      }
    }
  }

  void cool(int currentIteration) =>
      tick *= 1.0 - currentIteration / DEFAULT_ITERATIONS;

  bool done() => tick < 1.0 / max(height, width);

  double randInt(Random random, int min, num max) {
    return (random.nextInt(max.toInt() - min + 1).toDouble() + min).toDouble();
  }

  void positionNodes() {
    var offset = getOffset(graph);
    var x = offset.dx;
    var y = offset.dy;
    var nodesVisited = <Node>[];
    var nodeClusters = <NodeCluster>[];
    for (final node in graph.items) {
      node.position = Offset(node.position.dx - x, node.position.dy - y);
    }

    for(final node in graph.items) {
      if (!nodesVisited.contains(node)) {
        nodesVisited.add(node);
        var cluster = findClusterOf(nodeClusters, node);
        if (cluster == null) {
          cluster = NodeCluster();
          cluster.add(node);
          nodeClusters.add(cluster);
        }

        followEdges(cluster, node, nodesVisited);
      }
    }

    positionCluster(nodeClusters);
  }

  void positionCluster(List<NodeCluster> nodeClusters) {
    combineSingleNodeCluster(nodeClusters);

    var cluster = nodeClusters[0];
    // move first cluster to 0,0
    cluster.offset(-cluster.rect.left, -cluster.rect.top);

    for (var i = 1; i < nodeClusters.length; i++) {
      var nextCluster = nodeClusters[i];
      var xDiff = nextCluster.rect.left - cluster.rect.right - CLUSTER_PADDING;
      var yDiff = nextCluster.rect.top - cluster.rect.top;
      nextCluster.offset(-xDiff, -yDiff);
      cluster = nextCluster;
    }
  }

  void combineSingleNodeCluster(List<NodeCluster> nodeClusters) {
    NodeCluster? firstSingleNodeCluster;

    for(final cluster in nodeClusters) {
      if (cluster.size() == 1) {
        if (firstSingleNodeCluster == null) {
          firstSingleNodeCluster = cluster;
        } else {
          firstSingleNodeCluster.concat(cluster);
        }
      }
    }

    nodeClusters.removeWhere((element) => element.size() == 1);
  }

  void followEdges(NodeCluster cluster, Node node, List nodesVisited) {
    for(final edge in graph.linksTo(node)) {
      final successor = edge.target;
      if (!nodesVisited.contains(successor)) {
        nodesVisited.add(successor);
        cluster.add(successor);

        followEdges(cluster, successor, nodesVisited);
      }
    }

    for(final edge in graph.linksTo(node)){
      final predecessor = edge.source;
      if (!nodesVisited.contains(predecessor)) {
        nodesVisited.add(predecessor);
        cluster.add(predecessor);

        followEdges(cluster, predecessor, nodesVisited);
      }
    }
  }

  NodeCluster? findClusterOf(List<NodeCluster> clusters, Node node) {
    final cluster =  clusters.where((element) => element.contains(node));
    if(cluster.isEmpty){
      return null;
    }else{
      cluster.first;
    }
  }

  Rect getRect(Graph graph) {
    var offsetMinX = double.infinity;
    var offsetMinY = double.infinity;

    var offsetMaxX = double.negativeInfinity;
    var offsetMaxY = double.negativeInfinity;

    for (final node in graph.items) {
      offsetMinX = min(offsetMinX, node.position.dx);
      offsetMinY = min(offsetMinY, node.position.dy);

      offsetMaxX = max(offsetMaxX, node.position.dx);
      offsetMaxY = max(offsetMaxY, node.position.dy);
    }

    return Rect.fromPoints(
        Offset(offsetMinX, offsetMinY), Offset(offsetMaxX, offsetMaxY));
  }

  Offset getOffset(Graph graph) {
    var offsetX = double.infinity;
    var offsetY = double.infinity;

    for(final node in graph.items){
      offsetX = min(offsetX, node.position.dx);
      offsetY = min(offsetY, node.position.dy);
    }

    return Offset(offsetX, offsetY);
  }
}

class NodeCluster {
  List<Node> nodes = [];

  Rect rect;

  NodeCluster() : rect = Rect.zero;

  void add(Node node) {
    nodes.add(node);

    if (nodes.length == 1) {
      rect = Rect.fromLTRB(
          node.position.dx,
          node.position.dy,
          node.position.dx + node.size.width,
          node.position.dy + node.size.height);
    } else {
      rect = Rect.fromLTRB(
          min(rect.left, node.position.dx),
          min(rect.top, node.position.dy),
          max(rect.right, node.position.dx + node.size.width),
          max(rect.bottom, node.position.dy + node.size.height));
    }
  }

  bool contains(Node node) => nodes.contains(node);

  int size() => nodes.length;

  void concat(NodeCluster cluster) {
    for (final node in cluster.nodes) {
      node.position = (Offset(rect.right + CLUSTER_PADDING, rect.top));
      add(node);
    }
  }

  void offset(double xDiff, double yDiff) {
    nodes.forEach((node) {
      node.position = (node.position + Offset(xDiff, yDiff));
    });

    rect.translate(xDiff, yDiff);
  }
}
