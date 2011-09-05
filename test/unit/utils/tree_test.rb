require 'test_helper'

class TreeTest < ActiveSupport::TestCase
  attr_reader :tree
  
  def setup
    @tree = Tipsy::Utils::Tree.new(File.join(Tipsy.root, 'public'), File.join(Tipsy.root, 'compiled'))
    @tree.excludes << 'skipped.txt'
    @tree.excludes << "normal/sub/skipped"
    @tree.collect!
  end

  test "Folders are excluded by name" do
    tree.folders.map(&:to_s).include?(File.join(tree.source_path, 'sub','skipped')).should == false
  end
  
  test "Folders above excluded folders are preserved" do
    tree.folders.map(&:to_s).include?(File.join(tree.source_path, 'normal', 'sub')).should == true
  end
  
  test "Files are excluded by name" do
    tree.files.map(&:to_s).include?(File.join(tree.source_path, 'normal', 'skipped.txt')).should == false
  end
  
  test "Folders of excluded files are preserved" do
    tree.folders.map(&:to_s).include?(File.join(tree.source_path, 'normal')).should == true
  end

  
end