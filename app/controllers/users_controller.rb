class UsersController < ApplicationController
  def index
    render json: User.all
  end

  def show
    render json: User.find(params[:id])
  end

  def create
    user = User.new(users_params)
    if user.save
      render json: user
    else
      render json: user.errors, status: 422
    end
  end

  def update
    user = User.find(params[:id])
    if user.update(users_params)
      render json: user
    else
      render json: user.errors, status: 422
    end
  end

  def destroy
    user = User.find(params[:id])
    user.destroy!
    render json: user
  end

  private

  def users_params
    params.require(:user).permit(:name, :school_id)
  end
end
