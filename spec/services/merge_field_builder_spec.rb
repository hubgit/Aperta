require 'rails_helper'

describe MergeFieldBuilder do
  class ThirdLevelSampleContext < TemplateContext
    def baz
      42
    end
  end

  class SecondLevelSampleContext < TemplateContext
    context :bar, type: :third_level_sample
    def blah
      'blah'
    end
  end

  class TopLevelSampleContext < TemplateContext
    contexts :foo, type: :second_level_sample
    def simple
      'so simple'
    end
  end

  describe '#merge_fields' do
    it 'expands subcontext merge fields' do
      expanded = [
        { name: :simple },
        { name: :foo, many: true, children: [
          { name: :blah },
          { name: :bar, children: [
            { name: :baz }
          ] }
        ] }
      ]
      merge_fields = MergeFieldBuilder.merge_fields(TopLevelSampleContext)
      expect(merge_fields).to eq(expanded)
    end
  end
end
