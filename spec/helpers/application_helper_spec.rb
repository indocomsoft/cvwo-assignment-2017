# frozen_string_literal: true

require "spec_helper"

describe ApplicationHelper do
  describe "#choose_fgcolour" do
    it "given black should return white" do
      expect(helper.choose_fgcolour("#000000")).to eq("#FFFFFF")
    end
    it "given white should return black" do
      expect(helper.choose_fgcolour("#FFFFFF")).to eq("#000000")
    end
    it "given blue should return white" do
      expect(helper.choose_fgcolour("#0000FF")).to eq("#FFFFFF")
    end
    it "given red should return black" do
      expect(helper.choose_fgcolour("#FF0000")).to eq("#000000")
    end
    it "given green should return black" do
      expect(helper.choose_fgcolour("#00FF00")).to eq("#000000")
    end
    it "given #BADA55 should return white" do
      expect(helper.choose_fgcolour("#BADA55")).to eq("#FFFFFF")
    end
  end
  describe "#gen_link" do
    it "generates link" do
      allow(helper).to receive(:params).and_return(ActionController::Parameters.new(controller: "tasks", action: "index"))
      arg = ["a", sort: "done", direction: "asc"]
      expect(helper.gen_link(arg)).to eq(link_to arg[0], arg[1].merge(controller: "tasks", action: "index"))
    end
  end
end
