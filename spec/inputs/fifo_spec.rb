# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/devutils/rspec/shared_examples"
require "logstash/inputs/fifo"

describe LogStash::Inputs::Fifo do

  let(:tempfile) { Tempfile.new("/tmp/fifo") }

  it "should be non-reloadable" do
    plugin = LogStash::Plugin.lookup("input", "fifo").new({ "path" => tempfile.path })
    expect(plugin.reloadable?).to be_falsey
  end

  it "should register without errors" do
    plugin = LogStash::Plugin.lookup("input", "fifo").new({ "path" => tempfile.path })
    expect { plugin.register }.to_not raise_error
  end

end
