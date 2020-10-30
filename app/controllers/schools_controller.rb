class SchoolsController < ApplicationController
  def index
    render json: Common::School.all
  end

  def show
    render json: Common::School.find(params[:id])
  end

  def create
    school = Common::School.new(school_params)
    if school.save
      render json: school
    else
      render json: school.errors, status: 422
    end
  end

  def update
    school = Common::School.find(params[:id])
    if school.update(school_params)
      render json: school
    else
      render json: school.errors, status: 422
    end
  end

  def destroy
    school = Common::School.find(params[:id])
    school.destroy!
    render json: school
  end

  private

  def school_params
    params.require(:school).permit(:name)
  end
end
