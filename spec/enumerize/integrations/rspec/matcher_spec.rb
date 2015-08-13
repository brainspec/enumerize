RSpec.describe Enumerize::Integrations::RSpec::Matcher do

  let(:model) do
    Class.new do
      extend Enumerize

      def self.name
        'Model'
      end
    end
  end

  subject do
    model.new
  end

  describe '#in' do

    context 'defined as array' do

      before do
        model.enumerize(:sex, :in => [:male, :female])
      end

      it 'accepts the right params as a array' do
        expect(subject).to enumerize(:sex).in(:male, :female)
      end

      it 'accepts the the right params in a different order' do
        expect(subject).to enumerize(:sex).in(:female, :male)
      end

      it 'rejects wrong params' do
        message = 'Expected Model to define enumerize :sex in: "boy", "girl"'
        expect do
          expect(subject).to enumerize(:sex).in(:boy, :girl)
        end.to fail_with(message)
      end

      it 'has the right message when negated' do
        message = 'Did not expect Model to define enumerize :sex in: "female", "male"'
        expect do
          expect(subject).to_not enumerize(:sex).in(:male, :female)
        end.to fail_with(message)
      end
    end

    context 'defined as hash' do

      before do
        model.enumerize(:sex, :in => { male: 0, female: 1 })
      end

      it 'accepts the right params as a array' do
        expect(subject).to enumerize(:sex).in(:male, :female)
      end

      it 'accepts the right params as a hash' do
        expect(subject).to enumerize(:sex).in(male: 0, female: 1)
      end

      it 'accepts the right params as a hash in a different order' do
        expect(subject).to enumerize(:sex).in(female: 1, male: 0)
      end

      it 'rejects wrong keys' do
        message = 'Expected Model to define enumerize :sex in: "{:boy=>0, :girl=>1}"'
        expect do
          expect(subject).to enumerize(:sex).in(boy: 0, girl: 1)
        end.to fail_with(message)
      end

      it 'rejects wrong values' do
        message = 'Expected Model to define enumerize :sex in: "{:male=>2, :female=>3}"'
        expect do
        expect(subject).to enumerize(:sex).in(male: 2, female: 3)
        end.to fail_with(message)
      end
    end

    it 'has the right description' do
      matcher = enumerize(:sex).in(:male, :female)
      expect(matcher.description).to eq('define enumerize :sex in: "female", "male"')
    end
  end

  describe '#with_default' do

    before do
      model.enumerize(:sex, :in => [:male, :female], default: :female)
    end

    it 'accepts the right default value' do
      expect(subject).to enumerize(:sex).in(:male, :female).with_default(:female)
    end

    it 'rejects the wrong default value' do
      message = 'Expected Model to define enumerize :sex in: "female", "male" with "male" as default value'
      expect do
        expect(subject).to enumerize(:sex).in(:male, :female).with_default(:male)
      end.to fail_with(message)
    end

    it 'rejects if the `in` is wrong with a correct default value' do
      message = 'Expected Model to define enumerize :sex in: "boy", "girl" with "female" as default value'
      expect do
        expect(subject).to enumerize(:sex).in(:boy, :girl).with_default(:female)
      end.to fail_with(message)
    end

    it 'has the right description' do
      matcher = enumerize(:sex).in(:male, :female).with_default(:female)
      message = 'define enumerize :sex in: "female", "male" with "female" as default value'
      expect(matcher.description).to eq(message)
    end
  end
end
