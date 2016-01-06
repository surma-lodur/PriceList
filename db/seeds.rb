
module Seeds
  def self.up
    PriceList::Models::Item.destroy_all
    PriceList::Models::ItemPrice.destroy_all
    [
    ].each do |url|
      PriceList::Models::Item.create_from_url(url)
    end
  end
end
