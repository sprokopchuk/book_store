module CheckoutHelper
  def fill_in_payment(credit_card)
    fill_in "checkout_form[credit_card][first_name]", with: credit_card[:first_name]
    fill_in "checkout_form[credit_card][last_name]", with: credit_card[:last_name]
    fill_in "checkout_form[credit_card][number]", with: credit_card[:number]
    fill_in "checkout_form[credit_card][exp_month]", with: credit_card[:exp_month]
    fill_in "checkout_form[credit_card][exp_year]", with: credit_card[:exp_year]
    fill_in "checkout_form[credit_card][cvv]", with: credit_card[:cvv]
  end

end
