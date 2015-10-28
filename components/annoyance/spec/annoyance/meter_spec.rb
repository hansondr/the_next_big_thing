require File.expand_path("../../../app/models/annoyance/meter", __FILE__)

module Annoyance
  describe Annoyance::Meter do
    it "should be calibrated on initialize" do
      meter = Annoyance::Meter.new(10)
      expect(meter.limit).to eq 10
    end

    it "should raise if anything but an Integer is given" do
      expect {
        meter = Annoyance::Meter.new(:a)
      }.to raise_exception ArgumentError
    end

    describe "#annoyance_level" do
      before do
        allow(Annoyance::Levels).to receive(:levels).and_return([
          "level 1!",
          "level 2!",
          "level 3!",
          "level 4!"
        ])
      end

      it "should raise if anything but an Integer is given" do
        expect {
          meter = Annoyance::Meter.new(5).annoyance_level("a")
        }.to raise_exception ArgumentError
      end

      it "should return the description of the appropriate level of annoyance" do
        meter = Annoyance::Meter.new(4)
        expect(meter.annoyance_level(1)).to eq "level 1!"
        expect(meter.annoyance_level(2)).to eq "level 2!"
        expect(meter.annoyance_level(3)).to eq "level 3!"
        expect(meter.annoyance_level(4)).to eq "level 4!"
      end

      it "should handle impossible user input gracefully" do
        meter = Annoyance::Meter.new(3)
        expect(meter.annoyance_level(-1)).to eq ""
      end


      it "should return empty string for count 0" do
        meter = Annoyance::Meter.new(99)
        expect(meter.annoyance_level(0)).to eq ""

        meter = Annoyance::Meter.new(15)
        expect(meter.annoyance_level(0)).to eq ""
      end

      it "should extrapolate from the last appropriate level of annoyance by duplicating the last character" do
        meter = Annoyance::Meter.new(8)
        expect(meter.annoyance_level(1)).to eq "level 1!"
        expect(meter.annoyance_level(2)).to eq "level 1!!"
        expect(meter.annoyance_level(3)).to eq "level 2!"
        expect(meter.annoyance_level(4)).to eq "level 2!!"
        expect(meter.annoyance_level(5)).to eq "level 3!"
        expect(meter.annoyance_level(6)).to eq "level 3!!"
        expect(meter.annoyance_level(7)).to eq "level 4!"
        expect(meter.annoyance_level(8)).to eq "level 4!!"
      end

      it "should extrapolate the last possible input by duplicating the whole result" do
        meter = Annoyance::Meter.new(4)
        expect(meter.annoyance_level(5)).to eq "level 4!level 4!"
        expect(meter.annoyance_level(6)).to eq "level 4!level 4!level 4!"
      end
    end

    describe "#annoyance_adjusted" do
      before do
        allow(Annoyance::Levels).to receive(:levels).and_return([
          "level 1!",
          "level 2!"
        ])
      end

      context "when this limit is not yet reached" do
        it "should annoyance adjust a given text by duplicating the last character" do
          meter = Annoyance::Meter.new(2)
          expect(meter.annoyance_adjusted("text.", 1)).to eq "text.level 1!"
        end
      end

      context "when this limit is reached" do
        it "should annoyance adjust a given text by replacing the text with duplicated annoyance messages" do
          meter = Annoyance::Meter.new(2)
          expect(meter.annoyance_adjusted("text.", 4)).to eq "level 2!level 2!level 2!"
        end
      end
    end
  end
end
