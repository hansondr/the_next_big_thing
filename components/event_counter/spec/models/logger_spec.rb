require "spec_helper"

module EventCounter
  describe EventCounter::Logger do
    describe "#log" do
      it "returns the new logged count" do
        expect(subject.log("some_object", "some_event")).to eq 1
        expect(subject.log("some_object", "some_event")).to eq 2
        expect(subject.log("some_object", "some_event")).to eq 3

        expect(subject.log("some_object", "some_other_event")).to eq 1
        expect(subject.log("some_other_object", "some_event")).to eq 1
      end
    end
  end
end
