class Admin::DegreesController < AdminController
  def index
    @degrees = Degree.all
  end
end
