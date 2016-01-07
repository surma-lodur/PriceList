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

  auth(:http_digest, realm: 'Protected Api', opaque: 'Login required') do |_username|
    # lookup the user's password here
    {
      PriceList::AuthConfig['username'] => PriceList::AuthConfig['password']
    }[PriceList::AuthConfig['username']]
  end

  get :authorize do
    { status: 'ok' }
  end

  resource :items do
    desc 'Create a Item.'
    params do
      requires :url, type: String, desc: 'Item URL'
    end
    post do
      present(
        PriceList::Models::Item.create_from_url(params[:url]),
        with: PriceList::Entities::Item
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
