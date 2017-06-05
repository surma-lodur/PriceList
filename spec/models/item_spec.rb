require 'spec_helper'

describe 'Item', type: :model do
  subject { FactoryGirl.build(:item)}

  context 'new item' do
    describe '.create_from_url' do
      it 'should successfully createa and parse one element' do
        expect(Item.create_from_url('http://localhost/product/12121')).to be_present
        expect(Item.count).to be(1)
        item =Item.last
        expect(item.title).to be_present
        expect(item.suppliers.count).to be(1)
        expect(item.item_prices.count).to be(1)
      end
    end # describe      '.create_from_url'
  
  end # context 'new item'
end
