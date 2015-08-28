module CheckoutHelper
  def fill_in_payment(credit_card, user)
    fill_in "user[credit_card_attributes][first_name]", with: credit_card[:first_name]
    fill_in "user[credit_card_attributes][last_name]", with: credit_card[:last_name]
    fill_in "user[credit_card_attributes][number]", with: credit_card[:number]
    fill_in "user[credit_card_attributes][exp_month]", with: credit_card[:exp_month]
    fill_in "user[credit_card_attributes][exp_year]", with: credit_card[:exp_year]
    fill_in "user[credit_card_attributes][cvv]", with: credit_card[:cvv]
    find('input[name="user[orders_attributes][0][credit_card_id]"]').set user.credit_card.id
  end

end
