class TasksController < ApplicationController
  include JwtAuthenticatable

  DEFAULT_LIMIT = 25

  def index
    limit = params[:limit] || DEFAULT_LIMIT
    page = params[:page] || 1
    filter = params[:filter]

    query_obj = {user_id: current_user.id}

    if filter.present?
      if ['true', 'false'].include?(filter.downcase)
        query_obj[:completed] = ActiveModel::Type::Boolean.new.cast(filter)
      else
        render json: { error: "Invalid filter value. Must be 'true' or 'false'." }, status: :unprocessable_entity and return
      end
    end

    tasks = Task.where(query_obj).limit(limit).offset((page.to_i - 1) * limit.to_i)


    total_count = Task.where(user_id: current_user.id).count
    total_pages = (total_count.to_f / limit.to_f).ceil

    render json: {
      tasks: tasks,
      pagination: {
        current_page: page,
        total_pages: total_pages,
        total_count: total_count,
        limit: limit
      }
    }
  end

  def show
    task = Task.find_by(id: params[:id], user_id: current_user.id)

    if task
      render json: task
    else
      render json: { error: "Task not found" }, status: 404
    end
  end

  def create
    task = Task.new(valid_create_params)
    task.user_id = current_user.id

    begin
      task.save
      render json: task
    rescue StandardError => e
      Rails.logger.error "Error creating task: #{e.message}"
      render json: { error: "Error creating task." }, status: 500
    end
  end

  def update
    task = Task.find_by(id: params[:id], user_id: current_user)

    if task
      task_data = {}
      task_data[:completed] = valid_update_params[:completed] if valid_update_params[:completed]
      task_data[:title] = valid_update_params[:title] if valid_update_params[:title]
      task_data[:note] = valid_update_params[:note] if valid_update_params[:note]
  

      begin
        task.update!(task_data)
        render json: task.reload
      rescue StandardError => e
        Rails.logger.error "Error updating task: #{e.message}"
        render json: { error: "Error updating task." }, status: 500
      end
    else
      render json: { error: "Task not found" }, status: 404
    end
  end

  def destroy
    task = Task.find_by(id: params[:id], user_id: current_user.id)

    if task
      begin
        task.destroy!
        render json: { message: "Task successfully deleted" }, status: :ok
      rescue StandardError => e
        Rails.logger.error "Error deleting task: #{e.message}"
        render json: { error: "Task could not be deleted." }, status: 500
      end
    else
      render json: { error: "Task not found" }, status: :not_found
    end
  end

  private
  def valid_create_params
    params.permit(ParamValidation::ADDTASK_PARAMS.map { |x| x.values.first })
  end

  def valid_update_params
    params.permit(ParamValidation::UPDATETASK_PARAMS.map { |x| x.values.first })
  end
end
