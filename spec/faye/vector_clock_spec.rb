require_relative 'faye_helper'
require 'vector_clock'

describe 'VectorClock' do

  describe '#supersedes?' do
    subject      { {'some_id'  => 3,
                    'other_id' => 2} }

    context 'when at least one value in subject is bigger than 
             the corresponding value in the provided vector' do
      let(:vector) { {'some_id'  => 3,
                      'other_id' => 1} }

      it 'returns true' do
        subject.supersedes?(vector).should be_true
      end
    end

    context 'when subject contains a key with value different from 0 that
             the vector contains no entry for' do
      let(:vector) { {'some_id'      => 3} }

      it 'returns true' do
        subject.supersedes?(vector).should be_true
      end
    end

    context 'when no value in subject is bigger than the corresponding
             value in the vector' do
      let(:vector) { {'some_id'  => 3,
                      'other_id' => 2} }

      it 'returns false' do
        subject.supersedes?(vector).should be_false
      end
    end
  end

end