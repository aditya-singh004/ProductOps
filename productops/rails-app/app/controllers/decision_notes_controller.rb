class DecisionNotesController < ApplicationController
  def create
    requirement = Requirement.find(params[:requirement_id])
    authorize! :manage_requirements, requirement.project
    note = requirement.decision_notes.new(note_params.merge(decided_by: current_user))
    if note.save
      redirect_to requirement, notice: "Decision recorded."
    else
      redirect_to requirement, alert: note.errors.full_messages.to_sentence
    end
  end

  private

  def note_params
    params.require(:decision_note).permit(:title, :decision, :rationale)
  end
end
