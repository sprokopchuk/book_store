RailsAdmin.config do |config|


  config.main_app_name = ['BookStore', 'Admin']
  ### Popular gems integration

  ## == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :user
    redirect_to main_app.root_path unless current_user.admin?
  end
  config.current_user_method(&:current_user)

  ## == Cancan ==
  config.authorize_with :cancan
  config.model Order do
    list do
      field :user
      field :total_price
      field :completed_date
      field :state, :state
    end
    state({
      events: {cancel: 'btn-danger', confirm: 'btn-warning', finish: 'btn-success'},
      states: {canceled: 'label-danger', in_delivery: 'label-warning', delivered: 'label-success'},
      disable: [:next_step_checkout]
    })
  end
  config.model Book do
    exclude_fields :ratings
  end
  config.model Author do
    object_label_method do
      :full_name
    end
    exclude_fields :books
  end
  config.model User do
    list do
      field :id
      field :email
      field :first_name
      field :last_name
      field :admin
      field :guest
    end
  end
  config.model Category do
    list do
      field :id
      field :title
    end
    exclude_fields :books
  end
  config.model Rating do
    list do
      field :id
      field :review
      field :rate
      field :user
      field :book
      field :state, :state
    end
      state({
        events: {reject: 'btn-warning', approve: 'btn-success'},
        states: {not_approved: 'label-danger', rejected: 'label-warning', approved: 'label-success'},
      })
  end
  config.model Delivery do
    list do
      field :id
      field :name
      field :price
    end
  end
  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new do
      except ['Order', 'OrderItem', 'Rating']
    end
    export
    bulk_delete
    show
    edit do
      except ['Order', 'OrderItem']
    end
    delete
    show_in_app
    state
    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end
