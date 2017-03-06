class CreditsController < ApplicationController
  before_action :set_credit, only: [:new, :create ]

  def index
    @credits = Credit.all
  end

  def show
  end

  def new
  end

  def create
    @credit.user = current_user
    @credit.save
    if current_user.stripeid == nil
      customer = Stripe::Customer.create(
            :email => params[:stripeEmail],
            :source  => params[:stripeToken],
            :account_balance => @credit.amount_cents
          )
      current_user.stripeid = customer.id
      current_user.save
    else
      customer = Stripe::Customer.retrieve(current_user.stripeid)
      customer.account_balance = @credit.amount_cents
      customer.save
    end

    # send money

    rescue Stripe::CardError => e
        flash[:error] = e.message
        redirect_to new_user_credit_path
  end

  def payable
    @credits = Credit.where(refund_at: Date.today)
    @credits.each do |credit|
      charge = Stripe::Customer.charge(
          :amount => credit.total_amount_cents,
          :currency => "eur",
          :description => "Credit Peanut du @credit.created_at",
          :customer => credit.user.stripeid,
        )
    end
  end


  private
  def credit_params
    params.require(:credit).permit(:amount, :interest, :refund_at)
  end

  def set_credit
    @credit = Credit.new(amount: session[:amount])
    @credit.refund_at = (Date.today + session[:nb_days].to_i.days)
    @credit.interest = @credit.amount * (session[:nb_days].to_i) / 100
    @credit.total_amount = @credit.amount + @credit.interest
  end

end



