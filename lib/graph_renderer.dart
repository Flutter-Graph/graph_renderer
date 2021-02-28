library graph_renderer;

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:graph/graph.dart';

part 'src/graph_view.dart';
part 'src/graph_viewport.dart';
part 'src/graph_node.dart';
part 'src/render_graph_view.dart';
part 'src/render_graph_node.dart';

part 'src/layout/algorithm.dart';
part 'src/layout/fruchterman_reingold_algorithm.dart';

part 'src/edges/edge_renderer.dart';
part 'src/edges/default_edge_renderer.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}
