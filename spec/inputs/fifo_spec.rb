# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/inputs/fifo"

describe LogStash::Inputs::Fifo do

  let(:tempfile) { Tempfile.new("/tmp/fifo") }

  it "should register without errors" do
    plugin = LogStash::Plugin.lookup("input", "fifo").new({ "path" => tempfile.path })
    expect { plugin.register }.to_not raise_error
  end

  it_behaves_like "an interruptible input plugin" do
    let(:config) { { "path" => "/dev/stdin" } }
  end

end
