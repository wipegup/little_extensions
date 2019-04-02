require 'rails_helper'

feature 'Navigation Bar' do
  background do
    @home        = {exact_text: 'Home',           href: '/'}
    @items       = {exact_text: 'Browse Items',   href: '/items'}
    @merchants   = {exact_text: 'View Merchants', href: '/merchants'}
    @cart        = {exact_text: 'Cart',           href: '/cart'}
    @profile     = {exact_text: 'Profile',        href: '/profile'}
    @dashboard_m = {exact_text: 'Dashboard',      href: '/dashboard'}
    @dashboard_a = {exact_text: 'Dashboard',      href: '/admin/dashboard'}
    @register    = {exact_text: 'Register',       href: '/register'}
    @login       = {exact_text: 'Log In',         href: '/login'}
    @logout      = {exact_text: 'Log Out',        href: '/logout'}
  end

  context 'as a Visitor' do
    it 'should show visitor navigation links' do
      visit root_path
      within 'nav.main-nav' do
        expect(page).to have_link(@home)
        expect(page).to have_link('Home', href: '/')
        expect(page).to have_link(@items)
        expect(page).to have_link(@merchant)
        expect(page).to have_link(@cart)
        expect(page).to have_link(@login)
        expect(page).to have_link(@register)

        expect(page).to_not have_link(@profile)
        expect(page).to_not have_link(@logout)
        expect(page).to_not have_link(@dashboard_m)
        expect(page).to_not have_link(@dashboard_a)
        @nav_content = page
      end

      visit items_path
      within 'nav.main-nav' do
        expect(page).to eq(@nav_content)
      end

      visit merchants_path
      within 'nav.main-nav' do
        expect(page).to eq(@nav_content)
      end

      visit cart_path
      within 'nav.main-nav' do
        expect(page).to eq(@nav_content)
      end

      visit login_path
      within 'nav.main-nav' do
        expect(page).to eq(@nav_content)
      end

      visit register_path
      within 'nav.main-nav' do
        expect(page).to eq(@nav_content)
      end
    end
  end
end
