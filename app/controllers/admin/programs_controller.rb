class Admin::ProgramsController < AdminController
  def index
    @programs = Program.all
  end

  def new
    @program = Program.new
  end

  def create
    @program = Program.new(program_params)
    @program.save!
    redirect_to admin_programs_path
    flash[:notice] = "#{current_partner.program_label} successfully created"
  rescue ActiveRecord::RecordInvalid
    render :new
  end

  def edit
    @program = Program.find(params[:id])
  end

  def update
    @program = Program.find(params[:id])
    @program.update_attributes!(program_params)
    redirect_to admin_programs_path
    flash[:notice] = "#{current_partner.program_label} successfully updated"
  rescue ActiveRecord::RecordInvalid
    redirect_to edit_admin_program_path(@program)
  end

  private

    def program_params
      params.require(:program).permit(:name,
                                      :is_active)
    end
end
