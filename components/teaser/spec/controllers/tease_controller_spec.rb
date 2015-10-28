require "spec_helper"

module Teaser
  describe TeaseController, type: :controller do
    before do
      #controller.stub(:inject_dependencies)
      allow(controller).to receive(:inject_dependencies)
    end

    describe "GET new" do
      it "should not fail" do
        expect {
          get :new, use_route: "teaser"
        }.to_not raise_exception
      end
    end

    describe "POST create" do
      it "should use the annoyance meter set to 20" do
        allow(controller).to receive(:inject_dependencies).and_call_original
        expect(Annoyance::Meter).to receive(:new).with(10)
        xhr :post, :create, use_route: "teaser"
      end

      it "should fail if no new_sign_up_entry parameter is given" do
        xhr :post, :create, use_route: "teaser"
        expect(response.status).to eq 400
        expect(response.body).to eq "Hey! Please call this right... I need a new signUp entry!"

        xhr :post, :create, new_sign_up_entry: nil, use_route: "teaser"
        expect(response.status).to eq 400
        expect(response.body).to eq "Hey! Please call this right... I need a new signUp entry!"
      end

      it "should fail if the given new_sign_up_entry already exists (and use the annoyance meter)" do
        mock_annoyance_meter = double("annoyance_meter", annoyance_adjusted: "Oh I am annoyed...")
        controller.instance_variable_set "@annoyance_meter", mock_annoyance_meter
        entry_manager = EmailSignup::EntryManager.new
        controller.instance_variable_set "@entry_manager", entry_manager
        entry = entry_manager.create "adam"

        event_counter = EventCounter::TestHelper.new_logger("email_signup_entry_#{entry.id}", "signup", 1)
        controller.instance_variable_set "@event_counter", event_counter

        xhr :post, :create, new_sign_up_entry: "adam", use_route: "teaser"
        expect(response.status).to eq 400
        expect(response.body).to eq "Oh I am annoyed..."
        expect(EventCounter::Logger::Count.first.count).to eq 2
      end

      it "should fail if the new entry cannot be saved" do
        entry_manager = double("entry_manager", create: false, find_by_email: nil)
        controller.instance_variable_set "@entry_manager", entry_manager

        xhr :post, :create, new_sign_up_entry: "something unsaveable", use_route: "teaser"
        expect(response.status).to eq 500
        expect(response.body).to eq "Hm... something went seriously wrong."
      end

      it "should be a success if the new entry can be saved" do
        entry_manager = double("entry_manager", create: true, find_by_email: nil)
        controller.instance_variable_set "@entry_manager", entry_manager

        xhr :post, :create, new_sign_up_entry: "something unsaveable", use_route: "teaser"
        expect(response.status).to eq 200
        expect(response.body).to eq "Thanks for signing up!"
      end
    end
  end
end
