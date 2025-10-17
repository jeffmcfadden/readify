require "test_helper"

class NodeScorerTest < TLDR

  def setup
    @node = Nokogiri::HTML::DocumentFragment.parse('<div><p>Sample text</p></div>').children.first
  end

  def test_basic_node_scorer
    score = Readify::NodeScorer.new.score(@node)
    assert score.is_a?(Numeric), "Score should be a numeric value"
    assert_equal 5, score
  end
end
