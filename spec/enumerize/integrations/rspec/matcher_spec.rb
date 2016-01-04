require 'active_record'

silence_warnings do
  ActiveRecord::Migration.verbose = false
  ActiveRecord::Base.logger = Logger.new(nil)
  ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
end

ActiveRecord::Base.connection.instance_eval do
  create_table :users do |t|
    t.string :sex
    t.string :role
    t.string :account_type
  end
end

class User < ActiveRecord::Base
  extend Enumerize

  enumerize :sex, :in => [:male, :female], scope: true
  enumerize :role, :in => [:user, :admin], scope: :having_role
  enumerize :account_type, :in => [:basic, :premium]
end

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

  describe 'without qualifier' do

    it 'accepts when has defined a enumerize' do
      model.enumerize(:sex, :in => [:male, :female])
      expect(subject).to enumerize(:sex)
    end

    it 'rejects when has not defined a enumerize' do
      message = 'Expected Model to define enumerize :sex'
      expect do
        expect(subject).to enumerize(:sex)
      end.to fail_with(message)
    end
  end

  describe '#in' do

    context 'defined as array' do

      before do
        model.enumerize(:sex, :in => [:male, :female])
      end

      it 'accepts the right params as an array' do
        expect(subject).to enumerize(:sex).in([:male, :female])
      end

      it 'accepts the right params as regular params' do
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

      it 'accepts the right params as an array' do
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

  describe '#with_i18n_scope' do

    context 'defined as string' do

      before do
        model.enumerize(:sex, :in => [:male, :female], i18n_scope: 'sex')
      end

      it 'accepts the right i18n_scope' do
        expect(subject).to enumerize(:sex).in(:male, :female).with_i18n_scope('sex')
      end

      it 'rejects the wrong i18n_scope' do
        message = 'Expected Model to define enumerize :sex in: "female", "male" i18n_scope: "gender"'
        expect do
          expect(subject).to enumerize(:sex).in(:male, :female).with_i18n_scope('gender')
        end.to fail_with(message)
      end
    end

    context 'defined as array' do

      before do
        model.enumerize(:sex, :in => [:male, :female], i18n_scope: ['sex', 'more.sex'])
      end

      it 'accepts the wrong i18n_scope' do
        expect(subject).to enumerize(:sex).in(:male, :female).with_i18n_scope(['sex', 'more.sex'])
      end

      it 'rejects the wrong i18n_scope' do
        message = 'Expected Model to define enumerize :sex in: "female", "male" i18n_scope: ["sex"]'
        expect do
          expect(subject).to enumerize(:sex).in(:male, :female).with_i18n_scope(['sex'])
        end.to fail_with(message)
      end
    end
  end

  describe '#with_predicates' do

    it 'accepts when predicates is defined as a boolean' do
      model.enumerize(:sex, :in => [:male, :female], predicates: true)
      expect(subject).to enumerize(:sex).in(:male, :female).with_predicates(true)
    end

    it 'accepts when predicates is defined as a hash' do
      model.enumerize(:sex, :in => [:male, :female], predicates: { prefix: true })
      expect(subject).to enumerize(:sex).in(:male, :female).with_predicates(prefix: true)
    end

    it 'rejects when predicates is not defined' do
      model.enumerize(:sex, :in => [:male, :female])
      message = 'Expected Model to define enumerize :sex in: "female", "male" predicates: true'
      expect do
        expect(subject).to enumerize(:sex).in(:male, :female).with_predicates(true)
      end.to fail_with(message)
    end
  end

  describe '#with_multiple' do

    it 'accepts when has defined the multiple' do
      model.enumerize(:sex, :in => [:male, :female], multiple: true)
      expect(subject).to enumerize(:sex).in(:male, :female).with_multiple(true)
    end

    it 'rejects when has not defined the multiple' do
      model.enumerize(:sex, :in => [:male, :female])
      message = 'Expected Model to define enumerize :sex in: "female", "male" multiple: true'
      expect do
        expect(subject).to enumerize(:sex).in(:male, :female).with_multiple(true)
      end.to fail_with(message)
    end
  end

  describe '#with_scope' do

    subject do
      User.new
    end

    it 'accepts when scope is defined as a boolean' do
      expect(subject).to enumerize(:sex).in(:male, :female).with_scope(true)
    end

    it 'accepts when scope is defined as a hash' do
      expect(subject).to enumerize(:role).in(:user, :admin).with_scope(scope: :having_role)
    end

    it 'rejects when scope is not defined' do
      message = 'Expected User to define enumerize :account_type in: "basic", "premium" scope: true'
      expect do
        expect(subject).to enumerize(:account_type).in(:basic, :premium).with_scope(true)
      end.to fail_with(message)
    end
  end
end
