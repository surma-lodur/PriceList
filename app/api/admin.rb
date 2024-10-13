class PriceList::Api::Admin < Grape::API
  version 'v1', using: :path
  format :json
  prefix :admin

  # TODO: fix error handling
  rescue_from PriceList::Exception
  error_formatter :txt, lambda { |message, _backtrace, _options, _env|
    "#{message}"
  }

  ##########
  ## Auth ##
  ##########
  http_basic do |username, password|
    username == PriceList::AuthConfig['username'] &&
      password == PriceList::AuthConfig['password']
  end

  get :authorize do
    { status: 'ok' }
  end

  ###########
  ## Lists ##
  ###########

  resource :lists do
    desc 'Create a List.'
    params do
      requires :title, type: String, desc: 'Name of the List'
    end
    post do
      present(
        List.create(title: params[:title]),
        with: PriceList::Entities::List
      )
    end

    desc 'update a List.'
    params do
      requires :id, type: String, desc: 'List ID.'
      optional :title, type: String, desc: 'List title'
    end
    put ':id' do
      present(
        Item.List(params[:id]).update_attribute(:title, params[:title])
      )
    end

    desc 'Delete a List.'
    params do
      requires :id, type: String, desc: 'List ID.'
    end
    delete '/:id' do
      list = List.find(params[:id])
      error!('not empty') if list.items.present?
      list.destroy
    end
  end

  ###########
  ## Items ##
  ###########
  resource :items do
    desc 'Create a Item.'
    params do
      requires :url, type: String, desc: 'Item URL'
      optional :list_id, type: Integer, desc: 'List ID'
    end
    post do
      present(
        Item.create_from_url(params[:url], params[:list_id]),
        with: PriceList::Entities::Item
      )
    end

    desc 'update a Item.'
    params do
      requires :id, type: String, desc: 'Item ID.'
      optional :list_id, type: Integer, desc: 'List ID'
    end
    put ':id' do
      present(
        Item.find(params[:id]).update_attribute(:list_id, params[:list_id])
      )
    end

    desc 'Delete a Item.'
    params do
      requires :id, type: String, desc: 'Item ID.'
    end
    delete '/:id' do
      Item.find(params[:id]).destroy
    end
  end

  resource :suppliers do
    desc 'Create a Supplier.'
    params do
      requires :url, type: String, desc: 'Item URL'
      requires :item_id, type: Integer, desc: 'Item ID'
    end

    post do
      present(
        Supplier.create(url: params[:url], item_id: params[:item_id]),
        with: PriceList::Entities::Supplier
      )
    end

    desc 'Disable an Supplier.'
    params do
      requires :id, type: Integer, desc: 'Supplier ID.'
    end
    put ':id/disable' do
      supplier = Supplier.find(params[:id])
      supplier.disable!
      present(
        supplier,
        with: PriceList::Entities::Supplier
      )
    end

    desc 'Enable an Supplier.'
    params do
      requires :id, type: Integer, desc: 'Supplier ID.'
    end
    put ':id/enable' do
      supplier = Supplier.find(params[:id])
      supplier.enable!
      present(
        supplier,
        with: PriceList::Entities::Supplier
      )
    end

    desc 'Delete a Supplier.'
    params do
      requires :id, type: String, desc: 'Suplier ID.'
    end
    delete '/:id' do
      Supplier.find(params[:id]).destroy
    end
  end
end
