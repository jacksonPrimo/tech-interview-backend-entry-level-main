class AbandonedCartsJob < ApplicationJob
  queue_as :default

  def perform
    Cart.where(abandoned: false).where("last_interaction_at <= ?", 3.hours.ago).find_each do |cart|
      cart.mark_as_abandoned
    end

    Cart.where(abandoned: true).where("last_interaction_at <= ?", 7.days.ago).find_each do |cart|
      cart.remove_if_abandoned
    end
  end
end
