require 'rails_helper'

RSpec.describe User, type: :model do
  before :each do
    @merchant = create(:merchant)
    @items = create_list(:item, 10,  user: @merchant, quantity: 160)
    @other_merchant = create(:merchant)
    @other_items = create_list(:item, 10, user:@other_merchant)

    @user_wash = create(:user, state:"Washington", city:"Seattle")
    @user_2 = create(:user, state:"Oregon")
    @utah_user = create(:user, state:"Utah", city: "nothere")
    @other_users = create_list(:user, 4, state:"California")

    @other_users.each do |user|
      orders = create_list(:shipped_order, 2, user:user)

      orders.each do |order|
        create(:fulfilled_order_item, ordered_price: 1.0, item:@other_items[2], quantity:2, order:order)
      end
    end

    @top_orders_user = create(:user, state:"Utah")
    @many_orders = create_list(:shipped_order, 50, user:@top_orders_user)
    @many_orders.each do |order|
      create(:fulfilled_order_item, ordered_price: 5.0, item:@items[1], quantity:10, order:order)
    end

    @other_many_orders = create_list(:shipped_order, 50, user:@top_orders_user)
    @other_many_orders.each do |order|
      create(:fulfilled_order_item, ordered_price: 10.0, item:@other_items[1], quantity:10, order:order)
    end

    @top_items_user = create(:user)
    @big_order = create(:shipped_order, user: @top_items_user)
    create(:fulfilled_order_item, ordered_price: 1.0, item:@items[0], quantity:1000, order:@big_order)

    @other_big_order = create(:shipped_order, user: @top_items_user)
      create(:fulfilled_order_item, ordered_price: 2.0, item: @other_items[0], quantity:900, order: @other_big_order)

    @shipped_order_utah = create(:shipped_order, user: @utah_user)
    create(:fulfilled_order_item, ordered_price: 0.1, quantity: 83, item:@items[9], order:@shipped_order_utah)

    @shipped_orders_user_wash = create_list(:shipped_order,4, user: @user_wash)
    create(:fulfilled_order_item, ordered_price: 3.0, quantity: 9, item:@items[9], order:@shipped_orders_user_wash[0])
    create(:fulfilled_order_item, ordered_price: 3.0, quantity: 4, item:@items[2], order:@shipped_orders_user_wash[1])
    create(:fulfilled_order_item, ordered_price: 3.0, quantity: 3, item:@items[3], order:@shipped_orders_user_wash[2])
    create(:fulfilled_order_item, ordered_price: 3.0, quantity: 1, item:@items[8], order:@shipped_orders_user_wash[3])

    @order_1 = create(:order, user: @user_wash)
    @order_2 = create(:order, user: @user_2)
    create(:fulfilled_order_item, item:@items[0], order:@order_1)
    create(:fulfilled_order_item, item:@items[0], order:@order_2)
    create(:fulfilled_order_item, item:@items[1], order:@order_2)

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
  end

  context 'instance methods' do
    it '.user_money_spent_by_merchant(merchant)' do
      expected = 1800
      actual = @top_items_user.user_money_spent_by_merchant(@other_merchant)
      expect(actual).to eq(expected)

      expected = 2500
      actual = @top_orders_user.user_money_spent_by_merchant(@merchant)
      expect(actual).to eq(expected)
    end

    it '.user_money_spent_total' do
      expected = 2800
      actual = @top_items_user.user_money_spent_total
      expect(actual).to eq(expected)

      expected = 7500
      actual = @top_orders_user.user_money_spent_total
      expect(actual).to eq(expected)
    end

    it '.total_user_orders' do
      expected = 100
      actual = @top_orders_user.total_user_orders

      expect(actual).to eq(expected)
    end
  end
end