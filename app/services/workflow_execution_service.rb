class WorkflowExecutionService
  def initialize(workflow, user)
    @workflow = workflow
    @user = user
    @execution = nil
    @node_results = {}
  end

  def execute
    @execution = @workflow.workflow_executions.create!(
      user: @user,
      status: 'running',
      started_at: Time.current
    )

    begin
      # Get all nodes in execution order (topological sort)
      execution_order = topological_sort

      # Execute each node in order
      execution_order.each do |node|
        execute_node(node)
      end

      # Get final output from output nodes
      output_nodes = @workflow.workflow_nodes.where(node_type: 'output')
      final_results = output_nodes.map do |node|
        {
          node_id: node.node_id,
          label: node.label,
          data: @node_results[node.id]
        }
      end

      # Build node_outputs keyed by node_id for easy UI lookups
      node_outputs = {}
      @workflow.workflow_nodes.each do |node|
        if @node_results.key?(node.id)
          result = @node_results[node.id]
          # Store the data array directly if it's a hash with :data key
          node_outputs[node.node_id] = result.is_a?(Hash) && result[:data] ? result[:data] : result
        end
      end

      @execution.update!(
        status: 'completed',
        completed_at: Time.current,
        result_data: {
          results: final_results,
          node_outputs: node_outputs,
          total_records: @node_results.values.sum { |r| r.is_a?(Hash) && r[:count] ? r[:count] : (r.is_a?(Array) ? r.count : 1) }
        },
        records_processed: final_results.sum { |r| r[:data].is_a?(Array) ? r[:data].count : 1 }
      )

      { success: true, execution: @execution }
    rescue StandardError => e
      @execution.update!(
        status: 'failed',
        completed_at: Time.current,
        error_message: e.message
      )
      { success: false, error: e.message, execution: @execution }
    end
  end

  private

  def topological_sort
    # Simple topological sort - nodes with no incoming connections first
    nodes = @workflow.workflow_nodes.to_a
    sorted = []
    remaining = nodes.dup

    while remaining.any?
      # Find nodes with no incoming connections (or all inputs satisfied)
      ready_nodes = remaining.select do |node|
        incoming = @workflow.workflow_connections.where(target_node: node)
        incoming.empty? || incoming.all? { |conn| @node_results.key?(conn.source_node_id) }
      end

      if ready_nodes.empty?
        # Circular dependency or error - just add remaining nodes
        sorted.concat(remaining)
        break
      end

      sorted.concat(ready_nodes)
      remaining -= ready_nodes
    end

    sorted
  end

  def execute_node(node)
    # Get input data from connected source nodes
    input_data = get_node_inputs(node)

    # Execute the service method
    service_name = node.service_name || node.node_type
    config = node.config || {}
    method_name = config['method'] || config[:method] || 'default'

    # Build inputs from config (excluding 'method' key)
    inputs = config.except('method', :method).symbolize_keys
    inputs[:data] = input_data if input_data

    result = WorkflowServiceRegistry.execute_service(service_name, method_name, inputs)

    if result[:success]
      @node_results[node.id] = result[:data] || result
    else
      raise "Node #{node.label || node.node_id} failed: #{result[:error]}"
    end
  end

  def get_node_inputs(node)
    # Get all incoming connections
    connections = @workflow.workflow_connections.where(target_node: node)

    if connections.empty?
      # No inputs - this is a source node
      return nil
    end

    # For now, take data from the first connection
    # In the future, could merge multiple inputs
    first_connection = connections.first
    source_node_id = first_connection.source_node_id
    @node_results[source_node_id]
  end
end
