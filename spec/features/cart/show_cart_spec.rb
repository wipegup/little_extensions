require 'rails_helper'

RSpec.describe 'Cart show page' do
  before :each do
    @item_1, @item_2, @item_3, @item_4 = create_list(:item, 4)
    @empty_cart_message = "Your cart is empty"
  end
  it 'Says the cart is empty if the cart is empty' do
    visit cart_path
    expect(page).to have_content(@empty_cart_message)
    expect(page).not_to have_button("Empty Cart")
  end

  it 'Does not say the cart is empty if there is an item in the cart' do
    visit item_path(@item_1)
    click_button "Add to Cart"

    visit cart_path
    expect(page).not_to have_content(@empty_cart_message)
    expect(page).to have_button("Empty Cart")
  end

  it 'Can empty the cart if there is an item in the cart and the "empty cart" is pressed' do
    visit item_path(@item_1)
    click_button "Add to Cart"

    visit cart_path
    click_button "Empty Cart"

    expect(current_path).to eq(cart_path)
    expect(page).to have_content(@empty_cart_message)
    expect(page).to have_content("Cart: 0")
  end

  it 'Shows all items I have added and the grand total', type: :view do
    visit item_path(@item_1)
    click_button "Add to Cart"

    2.times do
      visit item_path(@item_2)
      click_button "Add to Cart"
    end

    4.times do
      visit item_path(@item_4)
      click_button "Add to Cart"
    end

    visit cart_path

    within "#cart-item-#{@item_1.id}" do
      expect(page).to have_selector('div', class:"item-name", text:@item_1.name)
      expect(page).to have_selector('div', class:"item-merchant", text:@item_1.user.name)
      expect(page).to have_selector('div', class:"item-price", text:number_to_currency(@item_1.current_price))
      expect(page).to have_selector('div', class:"item-quantity", text:"1")

      expect(page).to have_xpath("//img[@src='#{@item_1.image_url}']")
      expect(page).to have_field('quantity', with:"1")
      expect(page).to have_button("Update")
      expect(page).to have_button("Remove")

      expect(page).to have_selector('div', class:"item-subtotal", text:"#{@item_1.current_price}")
    end

    within "#cart-item-#{@item_2.id}" do
      expect(page).to have_selector('div', class:"item-name", text:@item_2.name)
      expect(page).to have_selector('div', class:"item-merchant", text:@item_2.user.name)
      expect(page).to have_selector('div', class:"item-price", text:@item_2.current_price)
      expect(page).to have_selector('div', class:"item-quantity", text:"2")

      expect(page).to have_xpath("//img[@src='#{@item_2.image_url}']")
      expect(page).to have_field('quantity', with:"2")
      expect(page).to have_button("Update")
      expect(page).to have_button("Remove")

      expect(page).to have_selector('div', class:"item-subtotal", text:"#{number_to_currency(@item_2.current_price * 2)}")
    end

    within "#cart-item-#{@item_4.id}" do
      expect(page).to have_selector('div', class:"item-name", text:@item_4.name)
      expect(page).to have_selector('div', class:"item-merchant", text:@item_4.user.name)
      expect(page).to have_selector('div', class:"item-price", text:@item_4.current_price)
      expect(page).to have_selector('div', class:"item-quantity", text:"4")

      expect(page).to have_xpath("//img[@src='#{@item_4.image_url}']")
      expect(page).to have_field('quantity', with:"4")
      expect(page).to have_button("Update")
      expect(page).to have_button("Remove")

      expect(page).to have_selector('div', class:"item-subtotal", text:"#{number_to_currency(@item_4.current_price * 4)}")
    end

    expect(page).not_to have_selector('div', id:"cart-item-#{@item_3.id}")

    total = number_to_currency(@item_1.current_price + (@item_2.current_price * 2) + (@item_4.current_price * 4))
    expect(page).to have_selector('div', id:"cart-actions", text:total)
  end

  it 'can update quantities of items in the cart' do
    visit item_path(@item_1)
    click_button "Add to Cart"
    visit cart_path

    select 3, from: "quantity"
    click_button "Update"

    expect(current_path).to eq(cart_path)
    expect(page).to have_field('quantity', with:3 )
  end

  it 'upon updating a quantity to 0, that item is removed from the cart' do
    visit item_path(@item_1)
    click_button "Add to Cart"
    visit cart_path
    select 0, from: "quantity"
    click_button "Update"

    expect(current_path).to eq(cart_path)
    expect(page).to have_content(@empty_cart_message)
  end

  it 'upon clicking Remove Item, that item is removed from the cart' do
    visit item_path(@item_1)
    click_button "Add to Cart"
    visit cart_path
    click_button "Remove"

    expect(current_path).to eq(cart_path)
    expect(page).to have_content(@empty_cart_message)
  end

  it 'clicking remove item does not remove the other items' do
    visit item_path(@item_1)
    click_button "Add to Cart"
    visit item_path(@item_2)
    click_button "Add to Cart"
    visit cart_path

    within "#cart-item-#{@item_1.id}" do
      click_button "Remove"
    end

    expect(page).to have_content(@item_2.name)
    expect(page).not_to have_content(@item_1.name)
  end

  it 'says you must register / log in if you are browsing as a user' do
    visit item_path(@item_1)
    click_button "Add to Cart"
    visit cart_path

    within '#cart-actions' do
      expect(page).to have_content("You must register or log in to check out")
      expect(page).to have_link("log in", href: login_path)
      expect(page).to have_link("register", href: register_path)

      expect(page).not_to have_button("Check Out")
    end
  end

  it 'gives the option to checkout as a logged in user' do
    user = create(:user)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    visit item_path(@item_1)
    click_button "Add to Cart"
    visit cart_path

    within '#cart-actions' do
      expect(page).not_to have_content("You must register or log in to check out")
      expect(page).not_to have_link("log in", href: login_path)
      expect(page).not_to have_link("register", href: register_path)

      expect(page).to have_button("Check Out")
    end
  end

  it 'creates an Order upon clicking "Checkout"' do
    user = create(:user)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    visit item_path(@item_1)
    click_button "Add to Cart"
    visit cart_path
    click_button "Check Out"

    expect(current_path).to eq(profile_orders_path)
    expect(page).to have_content("Your order was created!")

    expect(page).to have_content("Cart: 0")
    order = Order.last
    expect(order.user_id).to eq(user.id)
    expect(page).to have_content("Order ID: #{order.id}")
  end
end

RSpec.describe 'partial for items in cart' ,type: :view do
  it 'shows all information' do
    item = create(:item)
    quantity = 3
    render 'carts/cart_item', item:item, quantity:quantity

    expect(rendered).to have_selector('div', id:"cart-item-#{item.id}")
    expect(rendered).to have_selector('div', class:"item-name", text:item.name)
    expect(rendered).to have_selector('div', class:"item-merchant", text:item.user.name)
    expect(rendered).to have_selector('div', class:"item-price", text:item.current_price)
    expect(rendered).to have_selector('div', class:"item-quantity", text:quantity)

    expect(rendered).to have_xpath("//img[@src='#{item.image_url}']")
    expect(rendered).to have_field('quantity', with:quantity)
    expect(rendered).to have_button("Update")
    expect(rendered).to have_button("Remove")

    expect(rendered).to have_selector('div', class:"item-subtotal", text:"#{number_to_currency(item.current_price * quantity)}")
  end
end
