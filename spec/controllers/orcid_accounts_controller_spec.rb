require 'rails_helper'

describe OrcidAccountsController do
  let(:user) { FactoryGirl.create :user }
  let(:orcid_account) { user.orcid_account }

  describe "#show" do
    subject(:do_request) do
      get :show, id: user.id, format: :json
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is signed in' do
      before do
        stub_sign_in(user)
      end

      it "calls the orcid account's serializer when rendering JSON" do
        do_request
        serializer = orcid_account.active_model_serializer.new(orcid_account, scope: orcid_account)
        expect(res_body.keys).to match_array(serializer.as_json.stringify_keys.keys)
      end
    end
  end

  describe "#clear" do
    subject(:do_request) do
      get :clear, id: user.id, format: :json
    end
    
    context 'when the user is signed in' do
      before do
        stub_sign_in(user)
      end

      it "calls orcid_account.reset!" do
        do_request
        expect(orcid_account).to_receive(:reset!)
      end
    end
    
  end

end
