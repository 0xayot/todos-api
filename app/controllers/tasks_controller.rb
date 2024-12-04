class TasksController < ApplicationController
  include JwtAuthenticatable

  def index
    tasks = Task.where(user_id: current_user.id)

    render json: {"tasks": tasks}
  end

  def uncompleted_tasks
    tasks = Task.all.where(completed: false)

    render json: {"tasks": tasks}
  end

  def completed_tasks
    tasks = Task.all.where(completed: true)

    render json: {"tasks": tasks}
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
    pp task
    task.user_id = current_user.id

    if task.save
      render json: task
    else
      render json: task.errors
    end
  end

  def update
    task = Task.find_by(id: params[:id], user_id: current_user)

    if task
      task_data = {}
      task_data[:completed] = valid_update_params[:completed] if valid_update_params[:completed]
      task_data[:title] = valid_update_params[:title] if valid_update_params[:title]
      task_data[:note] = valid_update_params[:note] if valid_update_params[:note]
  
      if task.update!(task_data)
        render json: task.reload
      else
        render json: task.errors
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
        render json: { error: "Task could not be deleted." }, status: :unprocessable_entity
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
