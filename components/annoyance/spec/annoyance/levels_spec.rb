require File.expand_path("../../../app/models/annoyance/levels", __FILE__)

module Annoyance
  describe Annoyance do
    describe ".levels" do
      it "should be an array of strings" do
        expect(Annoyance::Levels.levels).to be_an Array
        expect(Annoyance::Levels.levels.select { |level| level.is_a? String }.count).to eq Annoyance::Levels.levels.count
      end
    end
  end
end
