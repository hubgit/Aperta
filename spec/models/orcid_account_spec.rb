require 'rails_helper'

describe OrcidAccount do
  let(:orcid_account) do
    FactoryGirl.create(:orcid_account,
      identifier: '0000-0002-8398-4521',
      access_token: '77ca0753-a8ac-491b-a1c4-0dbaa0c486d0')
  end
  let(:orcid_key) { 'APP-PLM33GS3DKZ60O79' }
  let(:orcid_secret) { '056cab03-aebe-4cb2-86d1-0011184af5ee' }
  let(:cassette) { 'orcid_account' }

  around do |example|
    envs = {
      ORCID_KEY: orcid_key,
      ORCID_SECRET: orcid_secret,
      ORCID_SITE_HOST: 'sandbox.orcid.org',
      ORCID_API_HOST: 'api.sandbox.orcid.org',
      ORCID_API_VERSION: '1.2'
    }
    ClimateControl.modify(envs) do
      VCR.use_cassette(cassette, match_requests_on: [:uri, :method, :headers]) do
        example.run
      end
    end
  end

  describe '#exchange_code_for_token' do
    # Get this from after authorizing on orcid.org. Click on the oauth link, authorize aperta, and capture the authorization code from the callback.
    let(:authorization_code) { 'C3b6Z2' }
    # this is the orcid returned with the test account. Update this when refreshing the VCR cassettee
    let(:orcid_identifier) { '0000-0002-8398-4521' }
    let(:cassette) { 'orcid_authorization' }
    let(:orcid_account) do
      FactoryGirl.create(:orcid_account,
        identifier: nil,
        access_token: nil)
    end

    context 'server returns http error code' do
      let(:authorization_code) { 'ZZZZZZ' }
      let(:cassette) { 'orcid_authorization_failure_bad_code' }

      it 'raises OrcidAccount::APIError on an error message in message body' do
        expect do
          orcid_account.exchange_code_for_token(authorization_code)
        end.to raise_error(OrcidAccount::APIError)
      end
    end

    context 'server returns http error code' do
      let(:orcid_key) { 'Bogus-key' }
      let(:cassette) { 'orcid_authorization_failure_http_error_code' }

      it 'raises OrcidAccount::APIError on a non 200 response' do
        expect do
          orcid_account.exchange_code_for_token(authorization_code)
        end.to raise_error(OrcidAccount::APIError)
      end
    end

    it 'receives an access token' do
      orcid_account.exchange_code_for_token(authorization_code)
      expect(orcid_account.access_token).not_to be_empty
    end

    it 'saves the orcid identifier' do
      orcid_account.exchange_code_for_token(authorization_code)
      expect(orcid_account.identifier).to eq(orcid_identifier)
    end
  end

  describe '#update_orcid_profile!' do
    it 'updates the orcid profile' do
      orcid_account.update_orcid_profile!
      expect(orcid_account.profile_xml).to_not be_nil
      expect(orcid_account.profile_xml_updated_at).to_not be_nil
    end

    context 'no identifier' do
      let(:orcid_account) do
        FactoryGirl.create(:orcid_account,
          access_token: '77ca0753-a8ac-491b-a1c4-0dbaa0c486d0')
      end

      it 'raises OrcidAccount::APIError' do
        expect do
          orcid_account.update_orcid_profile!
        end.to raise_error(OrcidAccount::APIError)
      end
    end

    context 'no access_token' do
      let(:orcid_account) do
        FactoryGirl.create(:orcid_account,
          identifier: '0000-0002-8398-4521')
      end

      it 'raises OrcidAccount::APIError' do
        expect do
          orcid_account.update_orcid_profile!
        end.to raise_error(OrcidAccount::APIError)
      end
    end
  end

  describe '#profile_url' do
    context 'with identifier' do
      let(:orcid_account) do
        FactoryGirl.build_stubbed(:orcid_account, identifier: 'my_id')
      end
      let(:profile_url) { 'https://sandbox.orcid.org/my_id' }

      it 'returns the remote profile url' do
        expect(orcid_account.profile_url).to eq(profile_url)
      end
    end

    context 'without identifier' do
      let(:orcid_account) { FactoryGirl.build_stubbed(:orcid_account) }
      it 'returns nil' do
        expect(orcid_account.profile_url).to be_nil
      end
    end
  end

  describe '#access_token_valid' do
    context 'with expires_at and access_token' do
      let!(:orcid_account) do
        FactoryGirl.build_stubbed(:orcid_account, access_token: 'token', expires_at: Time.current.utc)
      end

      context 'expires_at is in the past' do
        it 'returns false' do
          Timecop.freeze(Time.current.utc + 5.seconds) do
            expect(orcid_account.access_token_valid).to be_falsy
          end
        end
      end

      context 'expires_at is in the future' do
        it 'returns false' do
          Timecop.freeze(Time.current.utc - 5.seconds) do
            expect(orcid_account.access_token_valid).to be_truthy
          end
        end
      end
    end

    context 'without expires_at' do
      let!(:orcid_account) do
        FactoryGirl.build_stubbed(:orcid_account,
          access_token: nil,
          expires_at: Time.current.utc + 50.seconds)
      end
      it 'returns false' do
        expect(orcid_account.access_token_valid).to be_falsy
      end
    end
  end

  describe '#status' do
    let!(:orcid_account) do
      FactoryGirl.build_stubbed(:orcid_account)
    end

    it 'is `unauthenticated` when access_token is falsy' do
      expect(orcid_account.status).to eq(:unauthenticated)
    end

    it 'is `authenticated` when access_token_valid is truthy' do
      allow(orcid_account).to receive(:access_token).and_return('token')
      allow(orcid_account).to receive(:access_token_valid).and_return(true)
      expect(orcid_account.status).to eq(:authenticated)
    end

    it 'is `access_token_expired` when access_token is truthy and access_token_valid is falsy' do
      allow(orcid_account).to receive(:access_token).and_return('token')
      allow(orcid_account).to receive(:access_token_valid).and_return(false)
      expect(orcid_account.status).to eq(:access_token_expired)
    end
  end
end