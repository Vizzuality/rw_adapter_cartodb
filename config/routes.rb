Rails.application.routes.draw do
  scope module: :v1, constraints: APIVersion.new(version: 1, current: true) do
    with_options only: [:index, :show], path: 'datasets' do |list_show_only|
      list_show_only.resources :connectors
    end
  end
end
