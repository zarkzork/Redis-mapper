require File.dirname(__FILE__) + '/spec_helper'

class Creature < RedisMapper::Base
  field :name
  field :race

  IMMORTALS = %w[Elf Wizard]

  index :immortals do |o|
    IMMORTALS.include?(o.race)
  end
end

class Word < RedisMapper::Base
  field :content

  index :by_length do |o|
    [true, o.content.to_s.length]
  end
end

describe RedisMapper::Index do
  it 'creates index for mapper' do
    Creature.create 'name' => 'Boromir', 'race' => 'Human'
    Creature.create 'name' => 'Legolas', 'race' => 'Elf'
    Creature.create 'name' => 'Frodo', 'race' => 'Hobbit'
    wizard = Creature.create 'name' => 'Gendalf', 'race' => 'Wizard'

    immortals = Creature.immortals.map(&:name)
    immortals.size.should == 2
    immortals.include?('Gendalf').should == true
    immortals.include?('Legolas').should == true

    wizard.delete

    Creature.immortals.map(&:name) == ['Legolas']
  end

  it 'it orders elements' do
    %w[Love Peace War Procrastination].each do |w|
      Word.create 'content' => w
    end

    Word.by_length.to_a.map(&:content).should == %w[Procrastination Peace Love War]
  end
end
