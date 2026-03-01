require 'rails_helper'

RSpec.describe AbandonedCartsJob, type: :job do
  describe '#perform' do
    let!(:active_cart) { create(:cart, last_interaction_at: 1.hour.ago, abandoned: false) }
    let!(:stale_cart) { create(:cart, last_interaction_at: 4.hours.ago, abandoned: false) }
    let!(:abandoned_cart) { create(:cart, last_interaction_at: 5.days.ago, abandoned: true) }
    let!(:dead_cart) { create(:cart, last_interaction_at: 8.days.ago, abandoned: true) }

    it 'marks inactive carts as abandoned and deletes carts older than 7 days' do
      described_class.new.perform

      expect(active_cart.reload.abandoned).to be_falsey
      expect(stale_cart.reload.abandoned).to be_truthy
      expect(Cart.exists?(abandoned_cart.id)).to be_truthy
      expect(Cart.exists?(dead_cart.id)).to be_falsey
    end
  end
end
