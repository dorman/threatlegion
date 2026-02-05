module Admin
  class WorkflowsController < BaseController
    before_action :set_workflow, only: [:show, :edit, :update, :destroy, :execute, :results, :node_data, :update_node_config]

    def index
      @workflows = Workflow.order(created_at: :desc).page(params[:page])
      @services = WorkflowServiceRegistry.all_services
    end

    def show
      @workflow_data = @workflow.to_react_flow_format
      @services = WorkflowServiceRegistry.all_services
      @service_info = @services.index_with { |s| WorkflowServiceRegistry.service_info(s) }
      @executions = @workflow.workflow_executions.recent.limit(10)
    end

    def new
      @workflow = Workflow.new
      @services = WorkflowServiceRegistry.all_services
    end

    def create
      @workflow = current_user.workflows.build(workflow_params)
      @workflow.status = 'draft'
      
      # Store API keys in config
      api_keys = {}
      api_keys['abuse_ch_api_key'] = params[:workflow][:abuse_ch_api_key] if params[:workflow][:abuse_ch_api_key].present?
      api_keys['abuseipdb_api_key'] = params[:workflow][:abuseipdb_api_key] if params[:workflow][:abuseipdb_api_key].present?
      @workflow.config = (@workflow.config || {}).merge(api_keys) if api_keys.any?

      if @workflow.save
        redirect_to admin_workflow_path(@workflow), notice: 'Workflow created successfully.'
      else
        @services = WorkflowServiceRegistry.all_services
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @workflow_data = @workflow.to_react_flow_format
      @services = WorkflowServiceRegistry.all_services
      @service_info = @services.index_with { |s| WorkflowServiceRegistry.service_info(s) }
    end

    def update
      if params[:workflow] && params[:workflow][:workflow_data]
        # Update from React Flow format (JSON request)
        begin
          # Access workflow_data directly from params without strong parameters
          workflow_data = params[:workflow][:workflow_data]
          nodes_data = workflow_data[:nodes] || workflow_data['nodes'] || []
          edges_data = workflow_data[:edges] || workflow_data['edges'] || []

          @workflow.from_react_flow_format(nodes_data, edges_data)
          
          # Only update other permitted params if they exist
          other_params = params[:workflow].except(:workflow_data).permit(:name, :description, :status, :config)
          @workflow.update(other_params) if other_params.any?

          render json: { success: true, message: 'Workflow updated successfully.' }
        rescue => e
          Rails.logger.error "Error updating workflow: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          render json: { success: false, error: e.message }, status: :unprocessable_entity
        end
      elsif @workflow.update(workflow_params)
        redirect_to admin_workflow_path(@workflow), notice: 'Workflow updated successfully.'
      else
        @workflow_data = @workflow.to_react_flow_format
        @services = WorkflowServiceRegistry.all_services
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @workflow.destroy
      redirect_to admin_workflows_path, notice: 'Workflow deleted successfully.'
    end

    def execute
      result = @workflow.execute(current_user)

      if result[:success]
        redirect_to results_admin_workflow_path(@workflow, execution_id: result[:execution].id),
                    notice: 'Workflow executed successfully.'
      else
        redirect_to admin_workflow_path(@workflow), alert: "Workflow execution failed: #{result[:error]}"
      end
    end

    def results
      @execution = @workflow.workflow_executions.find(params[:execution_id]) if params[:execution_id]
      @execution ||= @workflow.workflow_executions.recent.first
      @executions = @workflow.workflow_executions.recent.limit(20)
    end

    def service_info
      service_name = params[:service_name]
      info = WorkflowServiceRegistry.service_info(service_name)
      methods = WorkflowServiceRegistry.service_methods(service_name)

      render json: {
        service: info,
        methods: methods
      }
    end

    def node_data
      node_id = params[:node_id]
      node = @workflow.workflow_nodes.find_by(node_id: node_id)

      unless node
        render json: { error: 'Node not found' }, status: :not_found
        return
      end

      # Get the most recent execution for this workflow
      execution = @workflow.workflow_executions.recent.first

      if execution && execution.result_data
        # Find node output in execution results
        node_output = execution.result_data.dig('node_outputs', node_id) ||
                      execution.result_data.dig('results', node_id)

        render json: {
          node: {
            id: node.node_id,
            label: node.label,
            service_name: node.service_name,
            node_type: node.node_type,
            config: node.config || {}
          },
          data: node_output || [],
          execution_status: execution.status,
          execution_id: execution.id
        }
      else
        render json: {
          node: {
            id: node.node_id,
            label: node.label,
            service_name: node.service_name,
            node_type: node.node_type,
            config: node.config || {}
          },
          data: [],
          message: 'No execution data available. Execute the workflow to see results.'
        }
      end
    end

    def update_node_config
      node_id = params[:node_id]
      node = @workflow.workflow_nodes.find_by(node_id: node_id)

      # If node doesn't exist in database, create it
      unless node
        Rails.logger.info "Node #{node_id} not found, creating it..."
        label = params[:label]
        service_name = params[:service_name] || params[:config]&.dig(:service_name) || label&.downcase&.gsub(/[.\s]+/, '_')

        node = @workflow.workflow_nodes.create!(
          node_id: node_id,
          node_type: 'service',
          service_name: service_name,
          label: label || 'New Node',
          position_x: 100,
          position_y: 100,
          config: {}
        )
      end

      begin
        config = params[:config] || {}
        # Merge new config with existing config
        new_config = (node.config || {}).merge(config.to_unsafe_h)

        # Update label if provided
        label = params[:label]

        updates = { config: new_config }
        updates[:label] = label if label.present?

        if node.update(updates)
          render json: {
            success: true,
            node: {
              id: node.node_id,
              label: node.label,
              service_name: node.service_name,
              config: node.config
            }
          }
        else
          render json: { success: false, error: node.errors.full_messages.join(', ') }, status: :unprocessable_entity
        end
      rescue => e
        Rails.logger.error "Error updating node config: #{e.message}"
        render json: { success: false, error: e.message }, status: :unprocessable_entity
      end
    end

    private

    def set_workflow
      @workflow = Workflow.find(params[:id])
    end

    def workflow_params
      params.require(:workflow).permit(:name, :description, :status, :config)
    end
  end
end
