

def test_igraph():
    import igraph as ig
    from igraph import Graph
    g = ig.Graph.Famous("petersen")

    g2 = Graph.Tree(127, 2)
