require File.dirname(__FILE__) + '/spec_helper'


class Creature < RedisMapper::Base
  field 'name'
  field 'race'

  IMMORTALS = %w[Elf Wizard]

  index :immortals do |o|
    IMMORTALS.include?(o.race)
  end
end

describe RedisMapper::Index do
  it 'creates index for mapper' do
    Creature.create 'name' => 'Boromir', 'race' => 'Human'
    Creature.create 'name' => 'Legolas', 'race' => 'Elf'
    Creature.create 'name' => 'Frodo', 'race' => 'Hobbit'
    Creature.create 'name' => 'Gendalf', 'race' => 'Wizard'

    immortals = Creature.immortals.map(&:name)
    immortals.size.should == 2
    immortals.include?('Gendalf').should == true
    immortals.include?('Legolas').should == true
  end
end
