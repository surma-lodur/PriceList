# encoding: UTF-8

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
  auth(:http_digest, realm: 'Protected Api', opaque: 'Login required') do |_username|
    # lookup the user's password here
    {
      PriceList::AuthConfig['username'] => PriceList::AuthConfig['password']
    }[PriceList::AuthConfig['username']]
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
        PriceList::Models::List.create(title: params[:title]),
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
        PriceList::Models::Item.List(params[:id]).update_attribute(:title, params[:title])
      )
    end

    desc 'Delete a List.'
    params do
      requires :id, type: String, desc: 'List ID.'
    end
    delete '/:id' do
      PriceList::Models::List.find(params[:id]).destroy
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
        PriceList::Models::Item.create_from_url(params[:url], params[:list_id]),
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
        PriceList::Models::Item.find(params[:id]).update_attribute(:list_id, params[:list_id])
      )
    end

    desc 'Delete a Item.'
    params do
      requires :id, type: String, desc: 'Item ID.'
    end
    delete '/:id' do
      PriceList::Models::Item.find(params[:id]).destroy
    end
  end
end
