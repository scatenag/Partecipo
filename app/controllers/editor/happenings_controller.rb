# frozen_string_literal: true

# This controller manafe {Happening} model for editors
class Editor::HappeningsController < Editor::ApplicationController
  before_action :set_fact
  before_action :set_happening, only: %i[show edit update destroy export]

  # GET /editor/facts/:fact_id/happenings
  def index
    type = filter_params[:type] == 'history' ? 'history' : 'future'
    @text = ['detail ilike :text', { text: "%#{filter_params[:text]}%" }] if filter_params[:text].present?
    @pagy, @happenings = pagy(
      @fact.happenings.send(type).where(@text),
      items: 6
    )
  end

  # GET /editor/facts/:fact_id/happenings/:id
  def show; end

  # GET /editor/facts/fact_id/happenings/new
  def new
    @happening = @fact.happenings.new(repeat_for: 0, repeat_in: [1, 2, 3, 4, 5])
  end

  # GET /editor/facts/:fact_id/happenings/:id/edit
  def edit; end

  # POST /editor/happenings
  def create
    @happening = @fact.happenings.new(happening_params)

    if @happening.save
      render 'editor/facts/show'
    else
      render :new
    end
  end

  # PATCH/PUT /editor/facts/:fact_id/happenings/:id
  def update
    if @happening.update(happening_params)
      render action: :show
    else
      render :edit
    end
  end

  # DELETE /editor/facts/:fact_id/happenings/:id
  def destroy
    @happening.destroy
    redirect_to editor_root_path
  end

  # GET /editor/facts/:fact_id/happenings/:happening_id/tickets/export
  def export
    @tickets = [%w[Username Posti]] + @happening.tickets.includes(:user).all.map { |t| [t.user.username, t.seats] } + [['Totale', @happening.seats_count]]
    send_data @tickets.map(&:to_csv).join, filename: 'tickets.csv'
  end

  private

  # Set @fact beore each action
  def set_fact
    @fact = current_user.facts.find(params[:fact_id])
  end

  # Set @happening when needed
  def set_happening
    @happening = @fact.happenings.find(params[:id])
  end

  # Filter params for set an {Happening}
  def happening_params
    params.require(:happening).permit(:detail, :start_at, :start_sale_at, :stop_sale_at, :max_seats, :max_seats_for_ticket, :repeat_for, repeat_in: [])
  end

  # Filter params for search an {Happening}
  def filter_params
    params.fetch(:filter, {}).permit(:text, :type)
  end
end
