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

describe Event do
  let(:action_data) { { user: user, task: task, paper: task.paper } }
  let(:action) { double(klass) }
  let(:klass) { Class.new(BehaviorAction) }
  let(:user) { create(:user) }
  let(:journal) { create(:journal) }
  let(:task) { FactoryGirl.create(:task, :with_card, title: Faker::Lorem.sentence, paper: paper) }
  let(:paper) { create(:paper, journal: journal) }
  let(:event) { Event.new(name: :good_event, **action_data) }
  subject { event.trigger }

  describe 'event registry' do
    describe 'Event.register' do
      after(:each) { Event.deregister('my_event') }

      it 'should work' do
        Event.register('my_event')
        expect(Event.allowed_events).to include('my_event')
      end

      it 'should convert to a string' do
        Event.register(:my_event)
        expect(Event.allowed_events).to include('my_event')
      end
    end

    describe 'Event.allowed?' do
      before(:each) { Event.register('my_event') }
      after(:each) { Event.deregister('my_event') }

      it 'should work' do
        expect(Event.allowed?('my_event')).to be(true)
      end

      it 'should work with symbols' do
        expect(Event.allowed?(:my_event)).to be(true)
      end
    end

    describe 'Event.allowed_events_including_descendants' do
      let!(:klass) { Class.new(Event) }
      after(:each) { Event.deregister('my_event') }
      before(:each) { Event.register(:my_event) }
      before(:each) { klass.register(:other_event) }

      it 'should include the events registered for that class' do
        expect(Event.allowed_events_including_descendants).to include('my_event')
      end

      it 'should include the events registered for the subclass' do
        Event.register(:my_event)
        expect(Event.allowed_events_including_descendants).to include('other_event')
      end
    end
  end

  describe '#trigger' do
    before(:each) do
      Event.register(:good_event)
    end

    after(:each) do
      Event.deregister(:good_event)
    end

    it 'should error if the event is not registered' do
      expect { Event.new(name: :bad_event, paper: paper, task: nil, user: nil).trigger }.to raise_error(ArgumentError, /not registered/)
    end

    it 'should error if the paper is nil' do
      expect { Event.new(name: :good_event, paper: nil, task: nil, user: nil).trigger }.to raise_error(ArgumentError, /paper is required/)
    end

    it 'should error if triggered twice' do
      event.trigger
      expect { event.trigger }.to raise_error(StandardError, /already triggered/)
    end

    it 'should append to the ActivityFeed' do
      expect(Activity).to receive(:create!).with(
        feed_name: 'forensic',
        subject: task,
        activity_key: :good_event,
        user: user,
        message: "good_event triggered"
      )
      subject
    end

    context 'broadcasting' do
      let!(:need_to_preload_user) { [user] }

      it 'should broadcast to the pub/sub system' do
        expect(Notifier).to receive(:notify).with(
          event: :good_event,
          data: {
            paper: paper,
            task: task
          }
        )
        subject
      end
    end

    context 'when an behavior is defined' do
      let!(:behavior) do
        create(
          :test_behavior,
          event_name: :good_event
        )
      end

      let(:event) { Event.new(name: :good_event, paper: paper, user: user, task: nil) }

      it 'should call the call method with action parameters' do
        expect(paper.journal.behaviors).to receive(:where).with(event_name: :good_event).and_return([behavior])
        expect(behavior).to receive(:call).with(event)
        event.trigger
      end

      context 'when multiple journals are present' do
        let(:other_journal) { FactoryGirl.create(:journal) }
        let!(:paper) { FactoryGirl.create(:paper, journal: other_journal) }

        it 'should be scoped to the journal' do
          expect(paper.journal.behaviors).to receive(:where).with(event_name: :good_event).and_return([])
          expect(behavior).not_to receive(:call).with(event)
          event.trigger
        end
      end
    end

    describe 'exception handling' do
      let!(:behavior) do
        create(
          :test_behavior,
          event_name: :good_event
        )
      end

      let(:event) { Event.new(name: :good_event, paper: paper, user: user, task: nil) }

      before(:each) do
        expect(paper.journal.behaviors).to receive(:where).with(event_name: :good_event).and_return([behavior])
        expect(behavior).to receive(:call).with(event).and_raise(StandardError)
      end

      it 'should raise the exception in trigger' do
        expect { event.trigger }.to raise_error(StandardError)
      end

      it 'should not write to the activity feed if a behavior throws an exception' do
        expect do
          begin
            event.trigger
          rescue
            nil
          end
        end.not_to(change { Activity.count })
      end
    end
  end
end
