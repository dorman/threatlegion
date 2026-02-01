module Admin
  class WorkflowsController < BaseController
    before_action :set_workflow, only: [:show, :edit, :update, :destroy, :execute, :results]

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
        workflow_data = params[:workflow][:workflow_data]
        nodes_data = workflow_data[:nodes] || []
        edges_data = workflow_data[:edges] || []

        @workflow.from_react_flow_format(nodes_data, edges_data)
        @workflow.update(workflow_params.except(:workflow_data))

        render json: { success: true, message: 'Workflow updated successfully.' }
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

    private

    def set_workflow
      @workflow = Workflow.find(params[:id])
    end

    def workflow_params
      params.require(:workflow).permit(:name, :description, :status, :config)
    end
  end
end
