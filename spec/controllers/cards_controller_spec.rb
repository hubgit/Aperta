# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'rails_helper'

describe CardsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:my_journal) { FactoryGirl.create(:journal) }
  let(:my_other_journal) { FactoryGirl.create(:journal) }
  let(:not_my_journal) { FactoryGirl.create(:journal) }

  describe 'GET index' do
    subject(:do_request) { get :index, format: :json }
    it_behaves_like "an unauthenticated json request"

    before do
      FactoryGirl.create(:card, :versioned, journal: my_journal, name: 'My Journal')
      FactoryGirl.create(:card, :versioned, journal: my_other_journal, name: 'My Other Journal')
      FactoryGirl.create(:card, :versioned, journal: not_my_journal, name: 'Not My Journal')
    end

    context 'and the user is signed in' do
      before do
        stub_sign_in(user)
        allow(user).to receive(:filter_authorized).and_return(
          instance_double(
            'Authorizations::Query::Result',
            objects: [my_journal, my_other_journal]
          )
        )
      end

      context 'for all journals' do
        it { is_expected.to responds_with 200 }

        it 'returns cards for journals the user has access to' do
          do_request
          journal_ids = res_body['cards'].map { |h| h['journal_id'] }.uniq
          expect(journal_ids).to contain_exactly(my_journal.id, my_other_journal.id)
        end
      end

      context 'for one journal' do
        it 'returns no cards for journals the user has no access to' do
          get :index, journal_id: not_my_journal.id, format: :json
          expect(res_body['cards'].count).to eq(0)
        end

        it 'returns all cards for the specified journal' do
          get :index, journal_id: my_journal.id, format: :json
          journal_ids = res_body['cards'].map { |h| h['journal_id'] }.uniq
          expect(journal_ids).to contain_exactly(my_journal.id)
        end
      end
    end
  end

  describe "#show" do
    subject(:do_request) do
      get :show, format: 'json', id: card.id
    end
    let(:card) { FactoryGirl.create(:card, :versioned) }

    it_behaves_like 'an unauthenticated json request'

    context 'and the user is signed in' do
      context 'when the user does not have access' do
        before do
          stub_sign_in(user)
          allow(user).to receive(:can?)
            .with(:view, card)
            .and_return false
          do_request
        end

        it { is_expected.to responds_with(403) }
      end

      context 'user has access' do
        before do
          stub_sign_in user
          allow(user).to receive(:can?).with(:view, card).and_return(true)
        end

        it { is_expected.to responds_with 200 }

        it 'returns the serialized card' do
          do_request
          expect(res_body['card']['id']).to be card.id
        end
      end
    end
  end

  describe "#create" do
    let(:card_task_type) do
      FactoryGirl.create(:card_task_type)
    end
    subject(:do_request) do
      post(:create, format: 'json', card: {
             name: name,
             journal_id: my_journal.id,
             card_task_type_id: card_task_type.id
           })
    end
    let(:name) { "Steve" }

    it_behaves_like 'an unauthenticated json request'

    context 'and the user is signed in' do
      context "when the user does not have access" do
        before do
          stub_sign_in(user)
          allow(user).to receive(:can?)
            .with(:create_card, my_journal)
            .and_return false
          do_request
        end

        it { is_expected.to responds_with(403) }
      end

      context 'user has access' do
        before do
          stub_sign_in user
          allow(user).to receive(:can?)
            .with(:create_card, my_journal)
            .and_return(true)
        end

        it { is_expected.to responds_with 201 }

        it 'returns the serialized draft card' do
          do_request
          expect(res_body['card']['name']).to eq name
          expect(res_body['card']['state']).to eq 'draft'
          expect(res_body['card']['card_task_type_id']).to eq card_task_type.id
        end
      end
    end
  end

  describe "#publish" do
    let(:card) { FactoryGirl.create(:card, :versioned, :draft, name: "Old Name") }
    subject(:do_request) do
      put(:publish, format: 'json', id: card.id, historyEntry: "Foo")
    end

    it_behaves_like 'an unauthenticated json request'

    context 'and the user is signed in' do
      context "and the user does not have access" do
        before do
          stub_sign_in(user)
          allow(user).to receive(:can?)
            .with(:edit, card)
            .and_return false
          do_request
        end

        it { is_expected.to responds_with(403) }
      end

      context 'and the user has access' do
        before do
          stub_sign_in user
          allow(user).to receive(:can?)
            .with(:edit, card)
            .and_return(true)
        end

        it { is_expected.to responds_with 200 }

        it 'publishes the card with the history entry and the current user' do
          allow(Card).to receive(:find).and_return card
          expect(card).to receive(:publish!).with("Foo", user)
          do_request
        end

        it 'serializes the latest card version' do
          expect(card.state).to eq('draft')
          do_request
          expect(res_body['card_version']['published_at']).to be_present
        end
      end
    end
  end

  describe "#revert" do
    let(:published_card) { FactoryGirl.create(:card, :versioned, :published_with_changes, name: "Published") }
    let(:unpublished_changes_card) { FactoryGirl.create(:card, :versioned, :published_with_changes, name: "Published with changes") }

    subject(:do_no_changes_request) do
      put(:revert, format: 'json', id: published_card.id)
    end

    subject(:do_request) do
      put(:revert, format: 'json', id: unpublished_changes_card.id)
    end

    it_behaves_like 'an unauthenticated json request'

    context 'and the user is signed in' do
      context "and the user does not have access" do
        before do
          stub_sign_in(user)
          allow(user).to receive(:can?)
            .with(:edit, unpublished_changes_card)
            .and_return false
          do_request
        end

        it { is_expected.to responds_with(403) }
      end

      context 'and the user has access' do
        context 'and the card had unpublished changes' do
          before do
            stub_sign_in user
            allow(user).to receive(:can?)
              .with(:edit, unpublished_changes_card)
              .and_return(true)
          end

          it { is_expected.to responds_with 200 }

          it 'returns the updated card' do
            expect(unpublished_changes_card.state).to eq('published_with_changes')
            do_request
            expect(res_body['card']['state']).to eq('published')
          end
        end
      end
    end
  end

  describe "#archive" do
    let(:card) { FactoryGirl.create(:card, :versioned, name: "Old Name") }
    subject(:do_request) do
      put(:archive, format: 'json', id: card.id)
    end

    it_behaves_like 'an unauthenticated json request'

    context 'and the user is signed in' do
      context "and the user does not have access" do
        before do
          stub_sign_in(user)
          allow(user).to receive(:can?)
            .with(:edit, card)
            .and_return false
          do_request
        end

        it { is_expected.to responds_with(403) }
      end

      context 'and the user has access' do
        before do
          stub_sign_in user
          allow(user).to receive(:can?)
            .with(:edit, card)
            .and_return(true)
        end

        it { is_expected.to responds_with 200 }

        it 'calls the CardArchiver' do
          expect(CardArchiver).to receive(:archive)
          do_request
        end

        it 'returns the updated card' do
          expect(card.state).to eq('published')
          do_request
          expect(res_body['card']['state']).to eq('archived')
        end
      end
    end
  end

  describe "#update" do
    let(:card) { FactoryGirl.create(:card, :versioned, name: "Old Name") }
    let(:card_params) do
      {
        name: name,
        journal_id: my_journal.id
      }
    end
    subject(:do_request) do
      post(:update, format: 'json', id: card.id, card: card_params)
    end
    let(:name) { "Steve" }

    it_behaves_like 'an unauthenticated json request'

    context 'and the user is signed in' do
      context "and the user does not have access" do
        before do
          stub_sign_in(user)
          allow(user).to receive(:can?)
            .with(:edit, card)
            .and_return false
          do_request
        end

        it { is_expected.to responds_with(403) }
      end

      context 'and the user has access' do
        before do
          stub_sign_in user
          allow(user).to receive(:can?)
            .with(:edit, card)
            .and_return(true)
        end

        it { is_expected.to responds_with 201 }

        it 'returns the updated card' do
          do_request
          expect(res_body['card']['name']).to eq name
        end

        context 'and the request includes xml' do
          let(:text) { Faker::Lorem.sentence }
          let(:xml) do
            <<-XML
              <card required-for-submission="false" workflow-display-only="false">
                <Description>
                  <text>#{text}</text>
                </Description>
              </card>
            XML
          end
          let(:card_params) do
            {
              name: name,
              journal_id: my_journal.id,
              xml: xml
            }
          end

          it 'updates the card' do
            expect { do_request }.to change { card.reload.latest_version }
            expect(card.reload.content_root_for_version(:latest).text).to eq(text)
          end

          it 'returns the updated card' do
            do_request
            expect(res_body['card']['xml']).to be_equivalent_to(xml)
          end
        end
      end
    end
  end

  describe "#destroy" do
    let(:card) { FactoryGirl.create(:card, :draft, :versioned, name: "Old Name") }
    let(:card_params) do
      {
        format: 'json',
        id: card.id
      }
    end

    subject(:do_request) do
      delete(:destroy, card_params)
    end

    context "the user has access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, card)
          .and_return true
      end

      it "deletes the card" do
        expect do
          do_request
        end.to change(Card, :count).by(-1)
      end

      it "responds with 204" do
        do_request
        expect(response.status).to eq(204)
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:edit, card)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end
end
