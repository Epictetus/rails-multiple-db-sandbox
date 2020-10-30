class SchoolsController < ApplicationController
  def index
    render json: School.all
  end

  def show
    render json: School.find(params[:id])
  end

  def create
    school = School.new(school_params)
    if school.save
      render json: school
    else
      render json: school.errors, status: 422
    end
  end

  def update
    school = School.find(params[:id])
    if school.update(school_params)
      render json: school
    else
      render json: school.errors, status: 422
    end
  end

  def destroy
    school = School.find(params[:id])
    school.destroy!
    render json: school
  end

  private

  def school_params
    params.require(:school).permit(:name)
  end
end
