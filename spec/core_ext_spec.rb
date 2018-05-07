require_relative "spec_helper"
require "upm/core_ext"

describe File do

  it "whiches" do
    File.which("ls").should == "/usr/bin/ls"
    File.which("ls", "rm").should == ["/usr/bin/ls", "/usr/bin/rm"]
    File.which("zzzzzzzzzzzzzzzzzzzzzzzzzzzz").should == nil
  end

  it "which_is_best?s" do
    File.which_is_best?("ls", "rm", "sudo").should == "/usr/bin/ls"
    File.which_is_best?("sudo").should == "/usr/bin/sudo"
    File.which_is_best?("zzzzzzzzzzzzzzzzzz").should == nil
  end

end