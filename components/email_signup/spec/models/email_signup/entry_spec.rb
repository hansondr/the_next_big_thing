require "spec_helper"

module EmailSignup
  describe EmailSignup::Entry do
    it { is_expected.to validate_presence_of :email }
    it { is_expected.to validate_uniqueness_of :email }
  end
end
