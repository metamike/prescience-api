module API
  module V1
    class Scenarios < Grape::API
      include API::V1::Defaults

      resource :scenarios do
        desc 'Return all Scenarios'
        get '', root: :scenarios do
          Scenario.all
        end

        desc 'Return a Scenario'
        params do
          requires :id, type: String, desc: 'ID of the Scenario'
        end
        get ':id', root: 'scenario' do
          Scenario.where(id: permitted_params[:id]).first!
        end

        desc 'Delete a Scenario'
        params do
          requires :id, type: String, desc: 'ID of the Scenario'
        end
        delete ':id', root: 'scenario' do
          Scenario.delete_all(id: permitted_params[:id])
        end
      end

    end
  end
end
